import Foundation
import SwiftData

@Model
final class GenerationItem {
    @Attribute(.unique) var id: UUID
    var type: String
    var prompt: String
    var output: String
    var platform: String
    var tone: String
    var createdAt: Date
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        type: String,
        prompt: String,
        output: String,
        platform: String,
        tone: String,
        createdAt: Date = .now,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.type = type
        self.prompt = prompt
        self.output = output
        self.platform = platform
        self.tone = tone
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}
