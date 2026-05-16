import SwiftData
import SwiftUI

struct SavedLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query(sort: \SavedContent.createdAt, order: .reverse) private var savedItems: [SavedContent]

    @State private var searchText = ""
    @State private var selectedType = "All"
    @State private var shareItem: ShareItem?
    @State private var showPaywall = false

    private var filterOptions: [String] {
        ["All"] + GeneratorTool.allCases.map(\.shortTitle)
    }

    private var filteredItems: [SavedContent] {
        savedItems.filter { item in
            let matchesSearch = searchText.isEmpty
                || item.title.localizedCaseInsensitiveContains(searchText)
                || item.body.localizedCaseInsensitiveContains(searchText)
                || item.platform.localizedCaseInsensitiveContains(searchText)

            let matchesType = selectedType == "All"
                || item.type.localizedCaseInsensitiveContains(typeKey(for: selectedType))

            return matchesSearch && matchesType
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                proBanner
                filterSection
                librarySection
            }
            .padding(20)
        }
        .navigationTitle("Library")
        .background(Color(.systemGroupedBackground))
        .searchable(text: $searchText, prompt: "Search saved content")
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.text])
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var header: some View {
        SparkCard {
            HStack(spacing: 14) {
                Image(systemName: "bookmark.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(.purple, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text("Saved Library")
                        .font(.title2.bold())
                    Text("Keep the hooks, scripts, captions, hashtag sets, and plans worth reusing.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(filterOptions, id: \.self) { option in
                    OptionPill(title: option, isSelected: selectedType == option) {
                        selectedType = option
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var proBanner: some View {
        if !subscriptionManager.hasProAccess {
            SparkCard {
                HStack(spacing: 14) {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                        .frame(width: 42, height: 42)
                        .background(.yellow.opacity(0.14), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved Library is a Pro workspace")
                            .font(.headline)
                        Text("Upgrade to save and export reusable hooks, scripts, captions, hashtags, and plans.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        showPaywall = true
                    } label: {
                        Image(systemName: "arrow.up.right")
                            .frame(width: 36, height: 36)
                            .background(.thinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var librarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if filteredItems.isEmpty {
                EmptyStateView(
                    systemImage: "tray",
                    title: "No saved content found",
                    message: "Save strong outputs from any generator and they will appear here."
                )
            } else {
                ForEach(filteredItems) { item in
                    NavigationLink {
                        SavedContentDetailView(item: item)
                    } label: {
                        SavedContentRow(
                            item: item,
                            onCopy: { Clipboard.copy(item.body) },
                            onShare: { shareItem = ShareItem(text: item.body) },
                            onDelete: { delete(item) }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func typeKey(for option: String) -> String {
        switch option {
        case "Hooks": "hook"
        case "Scripts": "script"
        case "Captions": "caption"
        case "Ideas": "trend"
        case "Hashtags": "hashtags"
        case "Plans": "calendar"
        default: ""
        }
    }

    private func delete(_ item: SavedContent) {
        modelContext.delete(item)
        try? modelContext.save()
    }
}

private struct SavedContentRow: View {
    @Bindable var item: SavedContent
    let onCopy: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    var body: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(item.type.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.purple)
                    }

                    Spacer()

                    Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(item.isFavorite ? .pink : .secondary)
                }

                Text(item.body)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(4)

                HStack {
                    Button(action: onCopy) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    Button(action: onShare) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Spacer()
                    Button(role: .destructive, action: onDelete) {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete saved content")
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.plain)
            }
        }
    }
}

private struct SavedContentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: SavedContent
    @State private var shareItem: ShareItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SparkCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(item.title)
                                .font(.title2.bold())
                            Spacer()
                            Button {
                                item.isFavorite.toggle()
                                try? modelContext.save()
                            } label: {
                                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(item.isFavorite ? .pink : .secondary)
                        }

                        Text("\(item.platform) • \(item.tone)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(item.body)
                            .font(.body)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        Clipboard.copy(item.body)
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    Button {
                        shareItem = ShareItem(text: item.body)
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .buttonStyle(.plain)
                .font(.subheadline.weight(.semibold))
            }
            .padding(20)
        }
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .sheet(item: $shareItem) { item in
            ShareSheet(items: [item.text])
        }
    }
}
