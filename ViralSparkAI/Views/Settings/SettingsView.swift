import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(UsageLimitManager.self) private var usageLimitManager

    @Query private var savedItems: [SavedContent]
    @Query private var generations: [GenerationItem]
    @Query private var plans: [ContentPlan]
    @Query private var posts: [PlannedPost]
    @Query private var profiles: [UserProfile]

    @State private var showPaywall = false
    @State private var showDeleteConfirmation = false
    @State private var shareItem: ShareItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                subscriptionCard
                settingsGroup(title: "Legal & Safety", documents: PolicyDocument.allCases)
                dataSection
                developerSection
            }
            .padding(20)
        }
        .navigationTitle("Settings")
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.text])
        }
        .confirmationDialog("Delete all saved data?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete All Data", role: .destructive, action: deleteAllData)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes profiles, generations, saved content, content plans, and planned posts from this device.")
        }
    }

    private var subscriptionCard: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 14) {
                    Image(systemName: subscriptionManager.hasProAccess ? "crown.fill" : "crown")
                        .font(.title2)
                        .foregroundStyle(subscriptionManager.hasProAccess ? .yellow : .purple)
                        .frame(width: 48, height: 48)
                        .background(.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 15, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(subscriptionManager.hasProAccess ? "Pro active" : "Free plan")
                            .font(.headline)
                        Text(subscriptionSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                PrimaryButton(
                    title: subscriptionManager.hasProAccess ? "Manage Subscription" : "Upgrade to Pro",
                    systemImage: "arrow.up.right",
                    action: { showPaywall = true }
                )
            }
        }
    }

    private func settingsGroup(title: String, documents: [PolicyDocument]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())

            SparkCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(documents) { document in
                        NavigationLink {
                            PolicyDocumentView(document: document)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: document.systemImage)
                                    .foregroundStyle(.purple)
                                    .frame(width: 28)
                                Text(document.title)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                        }
                        .buttonStyle(.plain)

                        if document.id != documents.last?.id {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data")
                .font(.title2.bold())

            SparkCard {
                VStack(spacing: 14) {
                    Button {
                        shareItem = ShareItem(text: ExportBuilder.savedLibraryText(items: savedItems))
                    } label: {
                        settingsRow(title: "Export saved content", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.plain)

                    Divider()

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        settingsRow(title: "Delete all saved data", systemImage: "trash")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var developerSection: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 8) {
                Label("Development mode", systemImage: "hammer.fill")
                    .font(.headline)
                Text(AppConfiguration.useMockAI ? "Mock AI responses are enabled by default." : "Live backend AI is enabled.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Free usage today: \(usageLimitManager.usageCount)/\(usageLimitManager.dailyLimit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var subscriptionSubtitle: String {
        if subscriptionManager.hasProAccess {
            return "Unlimited generation and Pro workflows are unlocked."
        }

        let remaining = usageLimitManager.remainingGenerations(isPro: false) ?? 0
        return "\(remaining) free generations left today."
    }

    private func settingsRow(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.purple)
                .frame(width: 28)
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
        }
        .font(.subheadline.weight(.semibold))
    }

    private func deleteAllData() {
        savedItems.forEach(modelContext.delete)
        generations.forEach(modelContext.delete)
        plans.forEach(modelContext.delete)
        posts.forEach(modelContext.delete)
        profiles.forEach(modelContext.delete)
        try? modelContext.save()
    }
}
