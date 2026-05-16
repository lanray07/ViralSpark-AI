import SwiftData
import SwiftUI

struct HomeDashboardView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(UsageLimitManager.self) private var usageLimitManager

    @Query(sort: \GenerationItem.createdAt, order: .reverse) private var generations: [GenerationItem]
    @Query(sort: \SavedContent.createdAt, order: .reverse) private var savedItems: [SavedContent]
    @Query(sort: \UserProfile.createdAt, order: .reverse) private var profiles: [UserProfile]

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 14)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HeaderSection(profile: profiles.first)
                UsageSection()
                QuickActionsSection(columns: columns)
                RecentGenerationsSection(items: Array(generations.prefix(4)))
                FavoritesSection(items: savedItems.filter(\.isFavorite).prefix(4).map { $0 })
            }
            .padding(20)
        }
        .navigationTitle("ViralSpark AI")
        .background(Color(.systemGroupedBackground))
    }
}

private struct HeaderSection: View {
    let profile: UserProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Creator cockpit")
                .font(.largeTitle.bold())
                .fixedSize(horizontal: false, vertical: true)

            Text(profile.map { "\($0.creatorType) • \($0.niche)" } ?? "Plan, draft, and save short-form ideas without the blank page.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct UsageSection: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(UsageLimitManager.self) private var usageLimitManager

    var body: some View {
        SparkCard {
            HStack(spacing: 14) {
                Image(systemName: subscriptionManager.hasProAccess ? "crown.fill" : "bolt.fill")
                    .font(.title2)
                    .foregroundStyle(subscriptionManager.hasProAccess ? .yellow : .purple)
                    .frame(width: 44, height: 44)
                    .background(.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(subscriptionManager.hasProAccess ? "Pro workspace active" : "Free generations")
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }

    private var subtitle: String {
        if subscriptionManager.hasProAccess {
            return "Unlimited generation, premium templates, and batch planning are unlocked."
        }

        let remaining = usageLimitManager.remainingGenerations(isPro: false) ?? 0
        return "\(remaining) of \(usageLimitManager.dailyLimit) generations remaining today."
    }
}

private struct QuickActionsSection: View {
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.title2.bold())

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(GeneratorTool.allCases) { tool in
                    NavigationLink(value: tool) {
                        QuickActionCard(tool: tool)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct QuickActionCard: View {
    let tool: GeneratorTool

    var body: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: tool.systemImage)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(tool.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(tool.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Image(systemName: "arrow.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct RecentGenerationsSection: View {
    let items: [GenerationItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent generations")
                .font(.title2.bold())

            if items.isEmpty {
                EmptyStateView(
                    systemImage: "sparkles.rectangle.stack",
                    title: "No generations yet",
                    message: "Use a quick action to create your first hook, script, caption, or plan."
                )
            } else {
                ForEach(items) { item in
                    SparkCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.type.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.purple)
                            Text(item.output)
                                .font(.subheadline)
                                .lineLimit(3)
                            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

private struct FavoritesSection: View {
    let items: [SavedContent]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved favorites")
                .font(.title2.bold())

            if items.isEmpty {
                EmptyStateView(
                    systemImage: "heart.text.square",
                    title: "Nothing saved yet",
                    message: "Favorite the strongest outputs so they are ready when it is time to post."
                )
            } else {
                ForEach(items) { item in
                    SparkCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(item.title, systemImage: "heart.fill")
                                .font(.headline)
                                .foregroundStyle(.pink)
                            Text(item.body)
                                .font(.subheadline)
                                .lineLimit(3)
                        }
                    }
                }
            }
        }
    }
}
