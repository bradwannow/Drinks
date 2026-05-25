import SwiftUI

struct HappyHourRow: View {
    let happyHour: HappyHour
    var showsStatus = false

    private var statusBadges: [FreshnessBadge] {
        FreshnessUtility.happyHourBadges(for: happyHour)
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImageView(
                url: happyHour.barImageURL,
                cornerRadius: AppSpacing.sm
            )
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                if showsStatus, !statusBadges.isEmpty {
                    FreshnessBadgeStrip(badges: statusBadges, maxVisible: 2)
                }

                Text(happyHour.barName)
                    .headlineStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(happyHour.dealDescription)
                    .bodyStyle()
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: AppSpacing.sm) {
                    Label(happyHour.timeRange, systemImage: "clock")
                    Label(happyHour.daysActive, systemImage: "calendar")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.accentMuted)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .fill(AppColors.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                        .strokeBorder(
                            showsStatus && statusBadges.contains(.happyHourNow)
                                ? AppColors.accent.opacity(0.35)
                                : AppColors.accent.opacity(0.15),
                            lineWidth: 1
                        )
                }
        }
        .cardShadow()
    }
}

#Preview {
    HappyHourRow(happyHour: MockDataService.happyHours[0], showsStatus: true)
        .padding()
        .screenBackground()
        .preferredColorScheme(.dark)
}
