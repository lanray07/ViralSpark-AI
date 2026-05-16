import Foundation
import SwiftData

@Model
final class SavedContent {
    @Attribute(.unique) var id: UUID
    var type: String
    var title: String
    var body: String
    var platform: String
    var tone: String
    var tagsData: String
    var createdAt: Date
    var isFavorite: Bool

    var tags: [String] {
        tagsData
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    init(
        id: UUID = UUID(),
        type: String,
        title: String,
        body: String,
        platform: String,
        tone: String,
        tagsData: String = "",
        createdAt: Date = .now,
        isFavorite: Bool = true
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.body = body
        self.platform = platform
        self.tone = tone
        self.tagsData = tagsData
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}
