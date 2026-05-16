import Foundation
import SwiftData

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var isPro: Bool
    var productID: String?
    var expiresAt: Date?
    var lastVerifiedAt: Date

    init(
        id: UUID = UUID(),
        isPro: Bool = false,
        productID: String? = nil,
        expiresAt: Date? = nil,
        lastVerifiedAt: Date = .now
    ) {
        self.id = id
        self.isPro = isPro
        self.productID = productID
        self.expiresAt = expiresAt
        self.lastVerifiedAt = lastVerifiedAt
    }
}
