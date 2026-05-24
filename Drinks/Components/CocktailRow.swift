import SwiftUI

struct CocktailRow: View {
    let cocktail: Cocktail
    var isSignature: Bool = false
    var showsChevron: Bool = true

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImageView(
                url: cocktail.imageURL,
                cornerRadius: AppSpacing.sm,
                showGradientOverlay: false
            )
            .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(cocktail.name)
                        .headlineStyle()
                        .lineLimit(1)

                    if isSignature {
                        BadgePill(title: "Signature", icon: "star.fill")
                    }
                }

                Text(cocktail.description)
                    .bodyStyle()
                    .lineLimit(2)

                Text(cocktail.spirit)
                    .labelStyle()
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(AppSpacing.md)
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
    CocktailRow(cocktail: MockDataService.featuredCocktail, isSignature: true)
        .padding()
        .screenBackground()
        .preferredColorScheme(.dark)
}
