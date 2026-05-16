import SwiftUI

enum GeneratorTool: String, CaseIterable, Identifiable, Hashable {
    case hook
    case script
    case caption
    case ideas
    case hashtags
    case plan

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hook:
            return "Generate Viral Hook"
        case .script:
            return "Generate Video Script"
        case .caption:
            return "Generate Caption"
        case .ideas:
            return "Generate Content Ideas"
        case .hashtags:
            return "Generate Hashtags"
        case .plan:
            return "Create Content Plan"
        }
    }

    var shortTitle: String {
        switch self {
        case .hook:
            return "Hooks"
        case .script:
            return "Scripts"
        case .caption:
            return "Captions"
        case .ideas:
            return "Ideas"
        case .hashtags:
            return "Hashtags"
        case .plan:
            return "Plans"
        }
    }

    var systemImage: String {
        switch self {
        case .hook:
            return "bolt.fill"
        case .script:
            return "text.bubble.fill"
        case .caption:
            return "captions.bubble.fill"
        case .ideas:
            return "lightbulb.fill"
        case .hashtags:
            return "number"
        case .plan:
            return "calendar.badge.plus"
        }
    }

    var kind: GenerationKind {
        switch self {
        case .hook:
            return .hook
        case .script:
            return .script
        case .caption:
            return .caption
        case .ideas:
            return .trendAngles
        case .hashtags:
            return .hashtags
        case .plan:
            return .calendar
        }
    }

    var accent: Color {
        switch self {
        case .hook:
            return .purple
        case .script:
            return .indigo
        case .caption:
            return .pink
        case .ideas:
            return .orange
        case .hashtags:
            return .teal
        case .plan:
            return .blue
        }
    }
}
