import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var subscriptionManager = SubscriptionManager()
    @State private var usageLimitManager = UsageLimitManager()

    private let aiService: any AIGenerating = AppConfiguration.useMockAI
        ? MockAIService()
        : NetworkAIService()

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .environment(\.aiService, aiService)
        .environment(subscriptionManager)
        .environment(usageLimitManager)
        .task {
            await subscriptionManager.start()
            usageLimitManager.refresh()
        }
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeDashboardView()
                    .withGeneratorRoutes()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                ContentCalendarView()
                    .withGeneratorRoutes()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }

            NavigationStack {
                SavedLibraryView()
                    .withGeneratorRoutes()
            }
            .tabItem {
                Label("Library", systemImage: "bookmark.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(.purple)
    }
}

private extension View {
    func withGeneratorRoutes() -> some View {
        navigationDestination(for: GeneratorTool.self) { tool in
            switch tool {
            case .hook:
                GeneratorScreen(tool: .hook)
            case .script:
                GeneratorScreen(tool: .script)
            case .caption:
                GeneratorScreen(tool: .caption)
            case .ideas:
                GeneratorScreen(tool: .ideas)
            case .hashtags:
                GeneratorScreen(tool: .hashtags)
            case .plan:
                GeneratorScreen(tool: .plan)
            }
        }
    }
}
