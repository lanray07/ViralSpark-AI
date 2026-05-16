import Foundation

enum AppConfiguration {
    static let useMockAI = true
    static let backendEndpoint = URL(string: "https://YOUR_BACKEND_URL.com/generate")!
    static let dailyFreeGenerationLimit = 5

    static let weeklyProductID = "com.viralsparkai.pro.weekly"
    static let monthlyProductID = "com.viralsparkai.pro.monthly"
    static let yearlyProductID = "com.viralsparkai.pro.yearly"
}
