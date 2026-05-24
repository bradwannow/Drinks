import SwiftUI

struct DiscoveryTile: View {
    let title: String
    let subtitle: String
    let imageURL: URL
    var icon: String? = nil

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImageView(
                url: imageURL,
                cornerRadius: AppSpacing.cardRadius,
                showGradientOverlay: true
            )
            .frame(width: 160, height: 120)

            LinearGradient(
                colors: [.clear, .black.opacity(0.75)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                }

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .padding(AppSpacing.sm)
        }
        .frame(width: 160, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .strokeBorder(AppColors.surfaceHighlight.opacity(0.5), lineWidth: 0.5)
        }
        .cardShadow()
    }
}

#Preview {
    DiscoveryTile(
        title: "Gin",
        subtitle: "4 cocktails",
        imageURL: MockDataService.featuredCocktail.imageURL,
        icon: "drop.fill"
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
