import SwiftUI

struct BarCard: View {
    let bar: Bar
    var style: Style = .compact

    enum Style {
        case compact
        case wide
    }

    var body: some View {
        switch style {
        case .compact:
            compactCard
        case .wide:
            wideCard
        }
    }

    private var compactCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImageView(
                url: bar.imageURL,
                cornerRadius: AppSpacing.cardRadius,
                showGradientOverlay: true
            )
            .frame(width: 200, height: 140)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(bar.name)
                    .headlineStyle()
                    .lineLimit(1)

                Text(bar.neighborhood)
                    .captionStyle()

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.accent)
                    Text(bar.formattedRating)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                    Text("·")
                        .foregroundStyle(AppColors.textTertiary)
                    Text(bar.formattedDistance)
                        .captionStyle()
                }
            }
            .padding(AppSpacing.sm)
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .strokeBorder(AppColors.surfaceHighlight.opacity(0.5), lineWidth: 0.5)
        }
        .cardShadow()
    }

    private var wideCard: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImageView(
                url: bar.imageURL,
                cornerRadius: AppSpacing.sm,
                showGradientOverlay: false
            )
            .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(bar.name)
                    .headlineStyle()

                Text(bar.tagline)
                    .bodyStyle()
                    .lineLimit(1)

                HStack(spacing: AppSpacing.xs) {
                    Text(bar.neighborhood)
                        .captionStyle()
                    Text("·")
                        .foregroundStyle(AppColors.textTertiary)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(AppColors.accent)
                        Text(bar.formattedRating)
                            .captionStyle()
                    }
                    Spacer()
                    Text(bar.formattedDistance)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
        .padding(AppSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .fill(AppColors.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                        .strokeBorder(AppColors.surfaceHighlight.opacity(0.5), lineWidth: 0.5)
                }
        }
        .cardShadow()
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        BarCard(bar: MockDataService.trendingBars[0], style: .compact)
        BarCard(bar: MockDataService.nearbyBars[0], style: .wide)
    }
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
