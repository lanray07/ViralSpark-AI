import SwiftUI

struct PillSelectionGrid: View {
    let options: [String]
    @Binding var selection: String
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 132), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(options, id: \.self) { option in
                OptionPill(
                    title: option,
                    isSelected: option == selection
                ) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                        selection = option
                    }
                }
            }
        }
    }
}

struct OptionPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 42)
                .padding(.horizontal, 12)
                .background(backgroundStyle, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(isSelected ? Color.purple.opacity(0.45) : Color.secondary.opacity(0.18))
                }
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? .white : .primary)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var backgroundStyle: some ShapeStyle {
        isSelected
        ? AnyShapeStyle(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
        : AnyShapeStyle(.thinMaterial)
    }
}
