import SwiftUI

struct HappyHourRow: View {
    let happyHour: HappyHour

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImageView(
                url: happyHour.barImageURL,
                cornerRadius: AppSpacing.sm
            )
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(happyHour.barName)
                    .headlineStyle()

                Text(happyHour.dealDescription)
                    .bodyStyle()
                    .lineLimit(2)

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
                        .strokeBorder(AppColors.accent.opacity(0.15), lineWidth: 1)
                }
        }
        .cardShadow()
    }
}

#Preview {
    HappyHourRow(happyHour: MockDataService.happyHours[0])
        .padding()
        .screenBackground()
        .preferredColorScheme(.dark)
}
