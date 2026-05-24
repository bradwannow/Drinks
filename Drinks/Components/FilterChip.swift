import SwiftUI

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    var isSelected = false
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    chipContent
                }
                .buttonStyle(.plain)
            } else {
                chipContent
            }
        }
    }

    private var chipContent: some View {
        HStack(spacing: AppSpacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
            }

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? AppColors.background : AppColors.textPrimary)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background {
            Capsule()
                .fill(isSelected ? AppColors.accent : AppColors.surface)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            isSelected ? AppColors.accent.opacity(0.8) : AppColors.surfaceHighlight.opacity(0.6),
                            lineWidth: 0.5
                        )
                }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    HStack {
        FilterChip(title: "Gin", icon: "drop.fill")
        FilterChip(title: "Happy Hour", icon: "clock.fill", isSelected: true)
    }
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
