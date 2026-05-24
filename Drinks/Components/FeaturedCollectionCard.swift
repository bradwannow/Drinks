import SwiftUI

struct FeaturedCollectionCard: View {
    let collection: FeaturedCollection

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageURL = collection.imageURL {
                AsyncImageView(
                    url: imageURL,
                    cornerRadius: AppSpacing.cardRadiusLarge,
                    showGradientOverlay: true
                )
            } else {
                RoundedRectangle(cornerRadius: AppSpacing.cardRadiusLarge, style: .continuous)
                    .fill(AppColors.surfaceHighlight)
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.2), .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: collection.icon)
                        .font(.system(size: 11, weight: .semibold))
                    Text("Collection")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                }
                .foregroundStyle(AppColors.accent)

                Text(collection.title)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2)

                Text(collection.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            .padding(AppSpacing.lg)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadiusLarge, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadiusLarge, style: .continuous)
                .strokeBorder(AppColors.surfaceHighlight.opacity(0.5), lineWidth: 0.5)
        }
        .elevatedShadow()
    }
}

#Preview {
    FeaturedCollectionCard(
        collection: FeaturedCollection(
            id: "seasonal",
            title: "Season's Best",
            subtitle: "Rotating pours for right now",
            icon: "leaf.fill",
            imageURL: MockDataService.cocktails[1].imageURL,
            filters: SearchFilters(seasonalOnly: true)
        )
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
