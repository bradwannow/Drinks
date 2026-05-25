import SwiftUI

struct MenuDiscoveryCard: View {
    let item: MenuDiscoveryItem

    var body: some View {
        PourCard(padding: 0, elevated: true) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    if let cover = item.version.coverImageURL {
                        AsyncImageView(url: cover, cornerRadius: 0)
                    } else {
                        AppColors.surfaceHighlight
                        Image(systemName: "doc.text.viewfinder")
                            .font(.title)
                            .foregroundStyle(AppColors.textTertiary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.75)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        FreshnessBadgeStrip(
                            badges: item.version.freshnessBadges(),
                            maxVisible: 2
                        )
                        Text(item.bar.name)
                            .font(.system(size: 16, weight: .semibold, design: .serif))
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(1)
                        Text(item.version.lastUpdatedLabel)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                    .padding(AppSpacing.sm)
                }
                .frame(width: 220, height: 160)

                HStack(spacing: AppSpacing.md) {
                    Label("\(item.version.cocktailCount)", systemImage: "wineglass")
                    Label("\(item.version.imageCount)", systemImage: "photo.on.rectangle")
                    if item.version.confirmationCount > 0 {
                        Label("\(item.version.confirmationCount)", systemImage: "checkmark.seal")
                    }
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
            }
            .frame(width: 220, alignment: .leading)
        }
    }
}

#Preview {
    MenuDiscoveryCard(
        item: MenuDiscoveryItem(
            version: MenuVersion(
                id: UUID(),
                menuID: UUID(),
                barID: UUID(),
                contributorID: nil,
                contributorName: "Alex",
                seasonLabel: "Spring",
                seasonMonth: 3,
                isCurrent: true,
                notes: nil,
                ocrStatus: .completed,
                uploadedAt: Date(),
                createdAt: Date(),
                versionNumber: 1,
                imageCount: 2,
                cocktailCount: 12,
                coverImageURL: MockDataService.featuredCocktail.imageURL,
                confirmationCount: 3,
                confidenceScore: 0.71,
                isOutdated: false
            ),
            bar: MockDataService.trendingBars[0]
        )
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
