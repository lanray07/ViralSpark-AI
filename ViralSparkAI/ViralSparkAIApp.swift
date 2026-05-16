import SwiftData
import SwiftUI

@main
struct ViralSparkAIApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [
            UserProfile.self,
            GenerationItem.self,
            SavedContent.self,
            ContentPlan.self,
            PlannedPost.self,
            SubscriptionState.self
        ])
    }
}
