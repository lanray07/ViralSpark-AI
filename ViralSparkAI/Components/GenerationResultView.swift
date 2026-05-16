import SwiftUI

struct GenerationResultView: View {
    let title: String
    let output: String
    let isFavorite: Bool
    let onCopy: () -> Void
    let onShare: () -> Void
    let onSave: () -> Void
    let onToggleFavorite: () -> Void
    let onRegenerate: () -> Void

    var body: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Label(title, systemImage: "sparkles")
                        .font(.headline)

                    Spacer()

                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(isFavorite ? .pink : .secondary)
                    .accessibilityLabel(isFavorite ? "Remove favorite" : "Favorite")
                }

                Text(output)
                    .font(.body)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ActionButton(title: "Copy", systemImage: "doc.on.doc", action: onCopy)
                        ActionButton(title: "Share", systemImage: "square.and.arrow.up", action: onShare)
                        ActionButton(title: "Save", systemImage: "bookmark", action: onSave)
                        ActionButton(title: "Regenerate", systemImage: "arrow.clockwise", action: onRegenerate)
                    }
                }
            }
        }
    }
}

private struct ActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(.thinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
