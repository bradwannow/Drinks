import SwiftUI

struct ActivityFeedCard: View {
    let entry: ActivityFeedEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                if let imageURL = entry.item.imageURL {
                    AsyncImageView(
                        url: imageURL,
                        cornerRadius: 0,
                        showGradientOverlay: true
                    )
                    .frame(width: 260, height: 140)
                } else {
                    AppColors.surfaceHighlight
                        .frame(width: 260, height: 140)
                }

                BadgePill(
                    title: entry.item.type.label,
                    icon: entry.item.type.icon,
                    tint: AppColors.accent
                )
                .padding(AppSpacing.sm)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(entry.item.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if let subtitle = entry.item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Text(entry.item.createdAt.formatted(.relative(presentation: .named)))
                    .captionStyle()
            }
            .padding(AppSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 260)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .strokeBorder(AppColors.accent.opacity(0.12), lineWidth: 1)
        }
        .cardShadow()
    }
}

#Preview {
    ActivityFeedCard(
        entry: ActivityFeedEntry(
            item: ActivityItem(
                id: UUID(),
                type: .seasonalDrop,
                title: "Root Beer Old Fashioned returns",
                subtitle: "Smoked cedar and bourbon reduction",
                barID: UUID(),
                cocktailID: UUID(),
                imageURL: MockDataService.featuredCocktail.imageURL,
                startsAt: Date(),
                endsAt: nil,
                createdAt: Date()
            ),
            cocktail: MockDataService.featuredCocktail,
            bar: nil
        )
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
