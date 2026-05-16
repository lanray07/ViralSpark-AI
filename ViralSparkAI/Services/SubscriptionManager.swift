import Foundation
import Observation
import StoreKit

private enum SubscriptionVerificationError: LocalizedError {
    case failed

    var errorDescription: String? {
        return "The transaction could not be verified."
    }
}

@MainActor
@Observable
final class SubscriptionManager {
    static let productIDs: [String] = [
        AppConfiguration.weeklyProductID,
        AppConfiguration.monthlyProductID,
        AppConfiguration.yearlyProductID
    ]

    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    var hasProAccess: Bool {
        !purchasedProductIDs.isEmpty
    }

    deinit {
        updatesTask?.cancel()
    }

    func start() async {
        listenForTransactions()
        await loadProducts()
        await updateCustomerProductStatus()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let loadedProducts = try await Product.products(for: Self.productIDs)
            products = loadedProducts.sorted { lhs, rhs in
                productSortIndex(lhs.id) < productSortIndex(rhs.id)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateCustomerProductStatus()
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateCustomerProductStatus() async {
        var activeProductIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                guard Self.productIDs.contains(transaction.productID) else { continue }
                activeProductIDs.insert(transaction.productID)
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        purchasedProductIDs = activeProductIDs
    }

    private func listenForTransactions() {
        guard updatesTask == nil else { return }

        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try await MainActor.run {
                        try self.checkVerified(result)
                    }
                    await self.updateCustomerProductStatus()
                    await transaction.finish()
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw SubscriptionVerificationError.failed
        }
    }

    private func productSortIndex(_ id: String) -> Int {
        Self.productIDs.firstIndex(of: id) ?? Int.max
    }
}
