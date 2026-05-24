import SwiftUI

struct SaveButton: View {
    let isSaved: Bool
    var style: Style = .toolbar
    let action: () -> Void

    enum Style {
        case toolbar
        case overlay
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                .font(.system(size: style == .toolbar ? 17 : 18, weight: .semibold))
                .foregroundStyle(isSaved ? AppColors.accent : AppColors.textPrimary)
                .symbolEffect(.bounce, value: isSaved)
                .frame(width: 40, height: 40)
                .background(backgroundMaterial)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSaved ? "Remove from saved" : "Save")
    }

    @ViewBuilder
    private var backgroundMaterial: some View {
        if style == .overlay {
            Circle()
                .fill(.ultraThinMaterial)
                .overlay {
                    Circle()
                        .strokeBorder(AppColors.surfaceHighlight.opacity(0.4), lineWidth: 0.5)
                }
        }
    }
}

#Preview {
    HStack(spacing: AppSpacing.lg) {
        SaveButton(isSaved: false, style: .toolbar) {}
        SaveButton(isSaved: true, style: .toolbar) {}
        SaveButton(isSaved: true, style: .overlay) {}
    }
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
