import SwiftUI

struct FreshnessBadgeStrip: View {
    let badges: [FreshnessBadge]
    var maxVisible: Int = 4

    var body: some View {
        if !badges.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.xs) {
                    ForEach(Array(badges.prefix(maxVisible))) { badge in
                        FreshnessBadgeView(badge: badge)
                    }
                }
            }
        }
    }
}

struct FreshnessBadgeView: View {
    let badge: FreshnessBadge

    var body: some View {
        BadgePill(title: badge.title, icon: badge.icon, tint: tint)
            .shadow(color: glowColor.opacity(badge.isGlow ? 0.35 : 0), radius: 8, y: 0)
    }

    private var tint: Color {
        switch badge {
        case .endingSoon, .tonightOnly, .startingSoon:
            return AppColors.accentSecondary
        case .happyHourNow, .trending:
            return AppColors.accent
        default:
            return AppColors.accentMuted
        }
    }

    private var glowColor: Color {
        switch badge {
        case .endingSoon, .tonightOnly, .startingSoon:
            return AppColors.accentSecondary
        default:
            return AppColors.accent
        }
    }
}

private extension FreshnessBadge {
    var isGlow: Bool {
        switch self {
        case .endingSoon, .tonightOnly, .startingSoon, .happyHourNow, .newThisWeek:
            return true
        default:
            return false
        }
    }
}

#Preview {
    FreshnessBadgeStrip(
        badges: [.newThisWeek, .staffPick, .tonightOnly, .trending]
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
