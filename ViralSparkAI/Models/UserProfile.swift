import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var creatorType: String
    var niche: String
    var contentGoal: String
    var hasAcceptedAIDisclosure: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        creatorType: String,
        niche: String,
        contentGoal: String,
        hasAcceptedAIDisclosure: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.creatorType = creatorType
        self.niche = niche
        self.contentGoal = contentGoal
        self.hasAcceptedAIDisclosure = hasAcceptedAIDisclosure
        self.createdAt = createdAt
    }
}
