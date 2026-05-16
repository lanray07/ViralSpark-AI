import SwiftData
import SwiftUI

struct ContentCalendarView: View {
    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(UsageLimitManager.self) private var usageLimitManager

    @Query(sort: \ContentPlan.generatedAt, order: .reverse) private var plans: [ContentPlan]
    @Query(sort: \PlannedPost.scheduledDate, order: .forward) private var posts: [PlannedPost]

    @State private var viewModel = ContentCalendarViewModel()
    @State private var showPaywall = false

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                planBuilder(viewModel: $viewModel)
                statusSection
                plansSection
                postsSection
            }
            .padding(20)
        }
        .navigationTitle("Calendar")
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var header: some View {
        SparkCard {
            HStack(spacing: 14) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text("Plan the next posts")
                        .font(.title2.bold())
                    Text("Generate weekly plans, store planned posts, and move each idea from drafted to posted.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func planBuilder(viewModel: Bindable<ContentCalendarViewModel>) -> some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Create plan")
                    .font(.headline)

                TextField("Campaign focus or niche", text: viewModel.focus, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...3)

                Text("Platform")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                PillSelectionGrid(options: Platform.allCases.map(\.rawValue), selection: viewModel.platform)

                HStack(spacing: 12) {
                    Button {
                        createPlan(days: 7)
                    } label: {
                        Label("7-Day Plan", systemImage: "calendar")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.wrappedValue.canGenerate || isLoading)

                    Button {
                        createPlan(days: 30)
                    } label: {
                        Label("30-Day", systemImage: "crown.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.wrappedValue.canGenerate || isLoading)
                }
            }
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .loading:
            SparkCard {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Building your posting plan...")
                        .font(.subheadline.weight(.semibold))
                }
            }
        case .loaded(_):
            if let notice = viewModel.notice {
                Label(notice, systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            }
        case .failed(let message):
            EmptyStateView(
                systemImage: "exclamationmark.triangle.fill",
                title: "Plan not created",
                message: message
            )
        case .limitReached:
            SparkCard {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Pro unlock", systemImage: "crown.fill")
                        .font(.headline)
                    Text("Upgrade for 30-day planning, unlimited generation, premium templates, saved library, and exports.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    PrimaryButton(title: "View Pro Plans", systemImage: "arrow.up.right") {
                        showPaywall = true
                    }
                }
            }
        }
    }

    private var plansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Plans")
                .font(.title2.bold())

            if plans.isEmpty {
                EmptyStateView(
                    systemImage: "calendar.badge.plus",
                    title: "No plans yet",
                    message: "Create a plan to populate your local content calendar."
                )
            } else {
                ForEach(plans) { plan in
                    SparkCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(plan.title)
                                    .font(.headline)
                                Spacer()
                                Text("\(plan.durationDays)d")
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.blue.opacity(0.12), in: Capsule())
                            }

                            Text(plan.focus)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(plan.generatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private var postsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Planned posts")
                .font(.title2.bold())

            if posts.isEmpty {
                EmptyStateView(
                    systemImage: "list.bullet.clipboard",
                    title: "No planned posts",
                    message: "Generated plans create local posts you can mark as drafted, filmed, edited, or posted."
                )
            } else {
                ForEach(posts) { post in
                    PlannedPostRow(post: post)
                }
            }
        }
    }

    private var isLoading: Bool {
        if case .loading = viewModel.state {
            return true
        }
        return false
    }

    private func createPlan(days: Int) {
        if days == 30 && !subscriptionManager.hasProAccess {
            showPaywall = true
            return
        }

        Task {
            await viewModel.createPlan(
                days: days,
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
}

private struct PlannedPostRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var post: PlannedPost
    @State private var reminderNotice: String?

    var body: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(post.title)
                            .font(.headline)
                        Text(post.scheduledDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Menu {
                        ForEach(PlannedPostStatus.allCases) { status in
                            Button(status.rawValue) {
                                updateStatus(status)
                            }
                        }
                    } label: {
                        Text(post.status)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.purple.opacity(0.12), in: Capsule())
                    }
                }

                Text(post.angle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(post.captionDraft)
                    .font(.subheadline)
                    .lineLimit(3)

                HStack {
                    Button {
                        Clipboard.copy(post.captionDraft)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }

                    Spacer()

                    Button {
                        scheduleReminder()
                    } label: {
                        Label("Reminder", systemImage: "bell")
                    }
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.plain)

                if let reminderNotice {
                    Text(reminderNotice)
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
    }

    private func updateStatus(_ status: PlannedPostStatus) {
        post.status = status.rawValue
        try? modelContext.save()
    }

    private func scheduleReminder() {
        let date = Calendar.current.date(byAdding: .hour, value: 9, to: post.scheduledDate) ?? post.scheduledDate
        post.reminderDate = date
        try? modelContext.save()

        Task {
            do {
                try await ReminderScheduler.scheduleReminder(for: post, at: date)
                reminderNotice = "Reminder scheduled"
            } catch {
                reminderNotice = error.localizedDescription
            }
        }
    }
}
