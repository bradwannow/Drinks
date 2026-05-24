import SwiftUI

struct RelatedCocktailCard: View {
    let cocktail: Cocktail

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            AsyncImageView(
                url: cocktail.imageURL,
                cornerRadius: AppSpacing.sm,
                showGradientOverlay: true
            )
            .frame(width: 140, height: 180)

            Text(cocktail.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)

            Text(cocktail.barName)
                .captionStyle()
                .lineLimit(1)

            Text(cocktail.spirit)
                .labelStyle()
        }
        .frame(width: 140)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            RelatedCocktailCard(cocktail: MockDataService.featuredCocktail)
            RelatedCocktailCard(cocktail: MockDataService.cocktails[1])
        }
        .padding()
    }
    .screenBackground()
    .preferredColorScheme(.dark)
}
