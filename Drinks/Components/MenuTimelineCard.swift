import SwiftUI

struct MenuTimelineCard: View {
    let version: MenuVersion

    var body: some View {
        PourCard(padding: 0, elevated: version.isCurrent) {
            HStack(spacing: 0) {
                ZStack {
                    if let coverURL = version.coverImageURL {
                        AsyncImageView(url: coverURL, cornerRadius: 0)
                    } else {
                        AppColors.surfaceHighlight
                        Image(systemName: "doc.text.viewfinder")
                            .font(.title2)
                            .foregroundStyle(AppColors.textTertiary)
                    }

                    if version.isCurrent {
                        LinearGradient(
                            colors: [AppColors.accent.opacity(0.35), .clear],
                            startPoint: .bottomLeading,
                            endPoint: .topTrailing
                        )
                    }
                }
                .frame(width: 96, height: 112)
                .clipped()

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.xs) {
                        Text(version.displayTitle)
                            .headlineStyle()
                            .lineLimit(1)

                        if version.isCurrent {
                            BadgePill(title: "Current", icon: "checkmark.circle.fill")
                        } else if version.isSeasonal {
                            BadgePill(title: "Seasonal", icon: "leaf.fill")
                        }
                    }

                    FreshnessBadgeStrip(badges: version.freshnessBadges(), maxVisible: 2)

                    Text(version.lastUpdatedLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.accentMuted)
                        .lineLimit(2)

                    HStack(spacing: AppSpacing.md) {
                        Label("\(version.imageCount)", systemImage: "photo.on.rectangle")
                        Label("\(version.cocktailCount)", systemImage: "wineglass")
                        if version.confirmationCount > 0 {
                            Label("\(version.confirmationCount)", systemImage: "checkmark.seal")
                        }
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)

                    if let contributor = version.contributorName {
                        Text("Captured by \(contributor)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColors.accentMuted)
                            .lineLimit(1)
                    }
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

#Preview {
    MenuTimelineCard(
        version: MenuVersion(
            id: UUID(),
            menuID: UUID(),
            barID: UUID(),
            contributorID: nil,
            contributorName: "Alex",
            seasonLabel: "Summer 2026",
            seasonMonth: 6,
            isCurrent: true,
            notes: nil,
            ocrStatus: .completed,
            uploadedAt: Date(),
            createdAt: Date(),
            versionNumber: 3,
            imageCount: 2,
            cocktailCount: 8,
            coverImageURL: MockDataService.featuredCocktail.imageURL,
            confirmationCount: 2,
            confidenceScore: 0.59,
            isOutdated: false
        )
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
