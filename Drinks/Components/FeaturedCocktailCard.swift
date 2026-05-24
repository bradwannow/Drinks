import SwiftUI

struct FeaturedCocktailCard: View {
    let cocktail: Cocktail

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImageView(
                url: cocktail.imageURL,
                cornerRadius: AppSpacing.cardRadiusLarge,
                showGradientOverlay: true
            )
            .frame(height: 320)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                if cocktail.isSeasonal {
                    Text("Seasonal Pick")
                        .labelStyle()
                } else {
                    Text("Featured")
                        .labelStyle()
                }

                Text(cocktail.name)
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)

                Text(cocktail.description)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)

                HStack(spacing: AppSpacing.sm) {
                    Label(cocktail.barName, systemImage: "mappin.circle.fill")
                    Label(cocktail.spirit, systemImage: "drop.fill")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.accentMuted)
            }
            .padding(AppSpacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadiusLarge, style: .continuous))
        .elevatedShadow()
        .glowShadow()
    }
}

#Preview {
    FeaturedCocktailCard(cocktail: MockDataService.featuredCocktail)
        .padding()
        .screenBackground()
        .preferredColorScheme(.dark)
}
