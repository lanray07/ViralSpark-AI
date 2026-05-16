import Foundation

enum ExportBuilder {
    static func savedLibraryText(items: [SavedContent]) -> String {
        guard !items.isEmpty else {
            return "No saved ViralSpark AI content yet."
        }

        return items.map { item in
            """
            # \(item.title)
            Type: \(item.type)
            Platform: \(item.platform)
            Tone: \(item.tone)
            Created: \(item.createdAt.formatted(date: .abbreviated, time: .shortened))

            \(item.body)
            """
        }
        .joined(separator: "\n\n---\n\n")
    }
}
