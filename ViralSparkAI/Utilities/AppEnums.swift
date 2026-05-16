import Foundation

enum CreatorType: String, CaseIterable, Identifiable, Codable {
    case tikTokCreator = "TikTok Creator"
    case youTuber = "YouTuber"
    case coach = "Coach"
    case smallBusiness = "Small Business"
    case freelancer = "Freelancer"
    case agency = "Agency"

    var id: String { rawValue }
}

enum ContentGoal: String, CaseIterable, Identifiable, Codable {
    case moreViews = "More views"
    case moreLeads = "More leads"
    case moreSales = "More sales"
    case moreConsistency = "More consistency"

    var id: String { rawValue }
}

enum Platform: String, CaseIterable, Identifiable, Codable {
    case tikTok = "TikTok"
    case instagramReels = "Instagram Reels"
    case youtubeShorts = "YouTube Shorts"
    case linkedIn = "LinkedIn"

    var id: String { rawValue }
}

enum ContentTone: String, CaseIterable, Identifiable, Codable {
    case bold = "Bold"
    case educational = "Educational"
    case funny = "Funny"
    case emotional = "Emotional"
    case controversial = "Controversial"
    case professional = "Professional"

    var id: String { rawValue }
}

enum GenerationKind: String, CaseIterable, Identifiable, Codable {
    case hook
    case script
    case caption
    case hashtags
    case calendar
    case trendAngles = "trend_angles"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hook:
            return "Viral Hook"
        case .script:
            return "Video Script"
        case .caption:
            return "Caption"
        case .hashtags:
            return "Hashtags"
        case .calendar:
            return "Content Plan"
        case .trendAngles:
            return "Content Ideas"
        }
    }
}

enum VideoLength: String, CaseIterable, Identifiable, Codable {
    case fifteen = "15s"
    case thirty = "30s"
    case sixty = "60s"

    var id: String { rawValue }
}

enum ScriptGoal: String, CaseIterable, Identifiable, Codable {
    case educate = "Educate"
    case sell = "Sell"
    case entertain = "Entertain"
    case buildTrust = "Build trust"

    var id: String { rawValue }
}

enum PlannedPostStatus: String, CaseIterable, Identifiable, Codable {
    case drafted = "Drafted"
    case filmed = "Filmed"
    case edited = "Edited"
    case posted = "Posted"

    var id: String { rawValue }
}
