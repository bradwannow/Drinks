import SwiftUI

struct BadgePill: View {
    let title: String
    var icon: String? = nil
    var tint: Color = AppColors.accent

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }

            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .textCase(.uppercase)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xxs + 2)
        .background {
            Capsule()
                .fill(tint.opacity(0.15))
                .overlay {
                    Capsule()
                        .strokeBorder(tint.opacity(0.35), lineWidth: 0.5)
                }
        }
    }
}

#Preview {
    HStack {
        BadgePill(title: "Featured", icon: "sparkles")
        BadgePill(title: "Seasonal", icon: "leaf.fill", tint: AppColors.accentSecondary)
        BadgePill(title: "Gin", icon: "drop.fill")
    }
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
