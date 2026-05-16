import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    let onComplete: () -> Void

    @State private var step = 0
    @State private var creatorType = CreatorType.tikTokCreator.rawValue
    @State private var niche = ""
    @State private var contentGoal = ContentGoal.moreViews.rawValue
    @State private var acceptedDisclosure = true

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.22),
                        Color.black.opacity(0.04),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    ProgressView(value: Double(step + 1), total: 5)
                        .tint(.purple)

                    TabView(selection: $step) {
                        WelcomeStep()
                            .tag(0)
                        CreatorTypeStep(selection: $creatorType)
                            .tag(1)
                        NicheStep(niche: $niche)
                            .tag(2)
                        GoalStep(selection: $contentGoal)
                            .tag(3)
                        DisclosureStep(acceptedDisclosure: $acceptedDisclosure)
                            .tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    PrimaryButton(
                        title: step == 4 ? "Start Creating" : "Continue",
                        systemImage: step == 4 ? "sparkles" : "arrow.right",
                        isDisabled: isCurrentStepDisabled,
                        action: advance
                    )
                }
                .padding(20)
            }
            .navigationTitle("ViralSpark AI")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var isCurrentStepDisabled: Bool {
        if step == 2 {
            return niche.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        if step == 4 {
            return !acceptedDisclosure
        }
        return false
    }

    private func advance() {
        if step < 4 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                step += 1
            }
            return
        }

        let profile = UserProfile(
            creatorType: creatorType,
            niche: niche,
            contentGoal: contentGoal,
            hasAcceptedAIDisclosure: acceptedDisclosure
        )
        modelContext.insert(profile)
        try? modelContext.save()
        onComplete()
    }
}

private struct WelcomeStep: View {
    var body: some View {
        OnboardingCard(
            systemImage: "sparkles",
            title: "Create short-form content faster",
            message: "Generate hooks, scripts, captions, hashtags, angles, and posting plans from one focused creator workspace."
        )
    }
}

private struct CreatorTypeStep: View {
    @Binding var selection: String

    var body: some View {
        OnboardingCard(systemImage: "person.crop.circle.badge.checkmark", title: "What kind of creator are you?") {
            PillSelectionGrid(
                options: CreatorType.allCases.map(\.rawValue),
                selection: $selection
            )
        }
    }
}

private struct NicheStep: View {
    @Binding var niche: String

    var body: some View {
        OnboardingCard(systemImage: "target", title: "Choose your niche") {
            VStack(alignment: .leading, spacing: 14) {
                TextField("Fitness coaching, SaaS marketing, local bakery...", text: $niche, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)

                Text("Be specific. ViralSpark uses this to make outputs more practical and platform-native.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct GoalStep: View {
    @Binding var selection: String

    var body: some View {
        OnboardingCard(systemImage: "chart.line.uptrend.xyaxis", title: "What are you optimizing for?") {
            PillSelectionGrid(
                options: ContentGoal.allCases.map(\.rawValue),
                selection: $selection
            )
        }
    }
}

private struct DisclosureStep: View {
    @Binding var acceptedDisclosure: Bool

    var body: some View {
        OnboardingCard(systemImage: "checkmark.shield.fill", title: "Review before posting") {
            VStack(alignment: .leading, spacing: 16) {
                Text("ViralSpark AI can help you draft content, but you are responsible for reviewing, editing, and fact-checking anything before publishing.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Text("The app avoids generating harmful, hateful, adult, illegal, or misleading content and may refuse unsafe requests.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Toggle("I understand and will review AI-generated content.", isOn: $acceptedDisclosure)
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

private struct OnboardingCard<Content: View>: View {
    let systemImage: String
    let title: String
    let message: String?
    let content: Content

    init(systemImage: String, title: String, message: String) where Content == EmptyView {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.content = EmptyView()
    }

    init(systemImage: String, title: String, @ViewBuilder content: () -> Content) {
        self.systemImage = systemImage
        self.title = title
        self.message = nil
        self.content = content()
    }

    var body: some View {
        SparkCard(padding: 22) {
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: systemImage)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.purple)
                    .frame(width: 72, height: 72)
                    .background(.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                Text(title)
                    .font(.largeTitle.bold())
                    .fixedSize(horizontal: false, vertical: true)

                if let message {
                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                content
            }
        }
    }
}
