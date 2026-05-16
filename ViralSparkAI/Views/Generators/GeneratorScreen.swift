import SwiftData
import SwiftUI

struct GeneratorScreen: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(UsageLimitManager.self) private var usageLimitManager

    @State private var viewModel: GeneratorViewModel
    @State private var shareItem: ShareItem?
    @State private var showPaywall = false

    init(tool: GeneratorTool) {
        _viewModel = State(initialValue: GeneratorViewModel(tool: tool))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                GeneratorHeader(tool: viewModel.tool)
                formSection(viewModel: $viewModel)
                advancedActionSection(viewModel: $viewModel)

                PrimaryButton(
                    title: primaryButtonTitle,
                    systemImage: "sparkles",
                    isLoading: isLoading,
                    isDisabled: !viewModel.canGenerate,
                    action: generate
                )

                stateSection
            }
            .padding(20)
        }
        .navigationTitle(viewModel.tool.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.text])
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var isLoading: Bool {
        if case .loading = viewModel.state {
            return true
        }
        return false
    }

    private var primaryButtonTitle: String {
        switch viewModel.tool {
        case .hook:
            return "Generate 10 Hooks"
        case .script:
            return "Generate Script"
        case .caption:
            return "Generate Captions"
        case .ideas:
            return "Generate 20 Ideas"
        case .hashtags:
            return "Generate Hashtags"
        case .plan:
            return "Create \(viewModel.planDays)-Day Plan"
        }
    }

    @ViewBuilder
    private func formSection(viewModel: Bindable<GeneratorViewModel>) -> some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 16) {
                Text(inputTitle)
                    .font(.headline)

                TextField(topicPlaceholder, text: viewModel.topic, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...5)

                if needsPlatform {
                    FormFieldTitle("Platform")
                    PillSelectionGrid(options: Platform.allCases.map(\.rawValue), selection: viewModel.platform)
                }

                if needsTone {
                    FormFieldTitle("Tone")
                    PillSelectionGrid(options: ContentTone.allCases.map(\.rawValue), selection: viewModel.tone)
                }

                if needsAudience {
                    FormFieldTitle("Audience")
                    TextField("Busy founders, first-time creators, local buyers...", text: viewModel.audience, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...3)
                }

                if viewModel.wrappedValue.tool == .script {
                    FormFieldTitle("Video length")
                    PillSelectionGrid(options: VideoLength.allCases.map(\.rawValue), selection: viewModel.videoLength)

                    FormFieldTitle("Goal")
                    PillSelectionGrid(options: ScriptGoal.allCases.map(\.rawValue), selection: viewModel.scriptGoal)
                }

                if viewModel.wrappedValue.tool == .plan {
                    FormFieldTitle("Plan length")
                    Picker("Plan length", selection: viewModel.planDays) {
                        Text("7 days").tag(7)
                        Text("30 days").tag(30)
                    }
                    .pickerStyle(.segmented)

                    if viewModel.wrappedValue.planDays == 30 && !subscriptionManager.hasProAccess {
                        Label("30-day content plans are included with Pro.", systemImage: "crown.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func advancedActionSection(viewModel: Bindable<GeneratorViewModel>) -> some View {
        if viewModel.wrappedValue.tool == .ideas {
            SparkCard {
                HStack(spacing: 14) {
                    Image(systemName: "rectangle.stack.badge.plus")
                        .font(.title2)
                        .foregroundStyle(.purple)
                        .frame(width: 44, height: 44)
                        .background(.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Batch Generate 30 Content Ideas")
                            .font(.headline)
                        Text("Pro-only batch ideation for campaign planning.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        batchGenerateIdeas()
                    } label: {
                        Image(systemName: "crown.fill")
                            .frame(width: 38, height: 38)
                            .background(.thinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Batch generate 30 content ideas")
                }
            }
        }
    }

    @ViewBuilder
    private var stateSection: some View {
        switch viewModel.state {
        case .idle:
            EmptyStateView(
                systemImage: "wand.and.stars",
                title: "Ready when you are",
                message: "Fill in the fields above and ViralSpark will draft a structured, editable output."
            )
        case .loading:
            SparkCard {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Generating a platform-native draft...")
                        .font(.subheadline.weight(.semibold))
                }
            }
        case .loaded(let output):
            VStack(spacing: 12) {
                if let notice = viewModel.notice {
                    Label(notice, systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                GenerationResultView(
                    title: viewModel.tool.shortTitle,
                    output: output,
                    isFavorite: viewModel.isFavorite,
                    onCopy: copyOutput,
                    onShare: shareOutput,
                    onSave: saveOutput,
                    onToggleFavorite: toggleFavorite,
                    onRegenerate: generate
                )
            }
        case .failed(let message):
            EmptyStateView(
                systemImage: "exclamationmark.triangle.fill",
                title: "Something needs attention",
                message: message
            )
        case .limitReached:
            SparkCard {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Upgrade to keep creating", systemImage: "crown.fill")
                        .font(.headline)
                    Text("Free users get \(AppConfiguration.dailyFreeGenerationLimit) generations per day. Pro unlocks unlimited generation, 30-day planning, saved library, exports, and premium templates.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    PrimaryButton(title: "View Pro Plans", systemImage: "arrow.up.right", action: {
                        showPaywall = true
                    })
                }
            }
        }
    }

    private var inputTitle: String {
        switch viewModel.tool {
        case .hook:
            return "Hook brief"
        case .script:
            return "Script brief"
        case .caption:
            return "Caption brief"
        case .ideas:
            return "Topic or niche"
        case .hashtags:
            return "Hashtag brief"
        case .plan:
            return "Plan focus"
        }
    }

    private var topicPlaceholder: String {
        switch viewModel.tool {
        case .hook:
            return "How to price coaching packages"
        case .script:
            return "3 mistakes new freelancers make"
        case .caption:
            return "A behind-the-scenes video about your offer"
        case .ideas:
            return "Personal finance for freelancers"
        case .hashtags:
            return "Launch week for a digital product"
        case .plan:
            return "Lead generation for a local service business"
        }
    }

    private var needsPlatform: Bool {
        viewModel.tool != .ideas
    }

    private var needsTone: Bool {
        switch viewModel.tool {
        case .script:
            return false
        default:
            return true
        }
    }

    private var needsAudience: Bool {
        switch viewModel.tool {
        case .caption, .ideas:
            return false
        default:
            return true
        }
    }

    private func generate() {
        Task {
            await viewModel.generate(
                aiService: aiService,
                usageLimitManager: usageLimitManager,
                isPro: subscriptionManager.hasProAccess,
                modelContext: modelContext
            )

            if case .limitReached = viewModel.state {
                showPaywall = true
            }
        }
    }

    private func batchGenerateIdeas() {
        guard subscriptionManager.hasProAccess else {
            showPaywall = true
            return
        }

        viewModel.contentCount = 30
        generate()
    }

    private func copyOutput() {
        Clipboard.copy(viewModel.exportText(isPro: subscriptionManager.hasProAccess))
        viewModel.notice = "Copied"
    }

    private func shareOutput() {
        shareItem = ShareItem(text: viewModel.exportText(isPro: subscriptionManager.hasProAccess))
    }

    private func saveOutput() {
        guard subscriptionManager.hasProAccess else {
            showPaywall = true
            return
        }

        viewModel.saveToLibrary(modelContext: modelContext)
    }

    private func toggleFavorite() {
        viewModel.toggleFavorite(modelContext: modelContext)
    }
}

private struct GeneratorHeader: View {
    let tool: GeneratorTool

    var body: some View {
        SparkCard {
            HStack(spacing: 14) {
                Image(systemName: tool.systemImage)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(tool.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(tool.title)
                        .font(.title2.bold())
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Practical, punchy, review-before-posting content for short-form channels.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct FormFieldTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}
