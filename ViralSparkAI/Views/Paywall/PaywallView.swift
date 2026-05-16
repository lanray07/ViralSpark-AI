import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    private let fallbackPlans = [
        FallbackPlan(name: "Weekly", price: "£4.99", id: AppConfiguration.weeklyProductID),
        FallbackPlan(name: "Monthly", price: "£14.99", id: AppConfiguration.monthlyProductID),
        FallbackPlan(name: "Yearly", price: "£99.99", id: AppConfiguration.yearlyProductID)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    featureList
                    productList
                    restoreSection
                }
                .padding(20)
            }
            .navigationTitle("ViralSpark Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .task {
                await subscriptionManager.loadProducts()
            }
        }
    }

    private var hero: some View {
        SparkCard(padding: 22) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.yellow)
                    .frame(width: 70, height: 70)
                    .background(.yellow.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text("Create without the daily ceiling")
                    .font(.largeTitle.bold())
                    .fixedSize(horizontal: false, vertical: true)

                Text("Pro unlocks unlimited generations, advanced hooks, the content calendar, saved library, exports, premium templates, and batch content generation.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var featureList: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 14) {
                PaywallFeature(text: "Unlimited generations")
                PaywallFeature(text: "Advanced hooks and premium templates")
                PaywallFeature(text: "7-day and 30-day content planning")
                PaywallFeature(text: "Saved library and script exports")
                PaywallFeature(text: "Batch generate 30 content ideas")
            }
        }
    }

    private var productList: some View {
        VStack(spacing: 12) {
            if subscriptionManager.products.isEmpty {
                ForEach(fallbackPlans) { plan in
                    fallbackProductRow(name: plan.name, price: plan.price)
                }
            } else {
                ForEach(subscriptionManager.products, id: \.id) { product in
                    productRow(product)
                }
            }

            if let errorMessage = subscriptionManager.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var restoreSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await subscriptionManager.restorePurchases() }
            } label: {
                Text("Restore Purchases")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in your Apple ID subscription settings.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func productRow(_ product: Product) -> some View {
        SparkCard {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(displayName(for: product))
                        .font(.headline)
                    Text(product.displayPrice)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    Task { await subscriptionManager.purchase(product) }
                } label: {
                    Text("Upgrade")
                        .font(.subheadline.weight(.bold))
                        .padding(.horizontal, 16)
                        .frame(height: 40)
                        .background(Color.purple, in: Capsule())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func fallbackProductRow(name: String, price: String) -> some View {
        SparkCard {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(name)
                        .font(.headline)
                    Text(price)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("Configure")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func displayName(for product: Product) -> String {
        if product.id == AppConfiguration.weeklyProductID { return "Weekly" }
        if product.id == AppConfiguration.monthlyProductID { return "Monthly" }
        if product.id == AppConfiguration.yearlyProductID { return "Yearly" }
        return product.displayName
    }
}

private struct FallbackPlan: Identifiable {
    let name: String
    let price: String
    let id: String
}

private struct PaywallFeature: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
    }
}
