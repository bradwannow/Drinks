import SwiftUI

struct MenuCocktailEntryRow: View {
    let entry: MenuCocktailEntry
    var changeKind: MenuCocktailChangeKind?

    var body: some View {
        PourCard {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.name)
                        .headlineStyle()

                    Spacer()

                    if let changeKind {
                        changeBadge(for: changeKind)
                    }

                    if let price = entry.priceText {
                        Text(price)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.accent)
                    }
                }

                if !entry.description.isEmpty {
                    Text(entry.description)
                        .bodyStyle()
                        .fixedSize(horizontal: false, vertical: true)
                }

                if entry.hasLowConfidence {
                    Text("Unverified OCR")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func changeBadge(for kind: MenuCocktailChangeKind) -> some View {
        switch kind {
        case .added:
            BadgePill(title: "New", icon: "plus", tint: AppColors.accent)
        case .seasonalReturn:
            BadgePill(title: "Return", icon: "leaf.fill", tint: AppColors.accentMuted)
        case .removed:
            EmptyView()
        }
    }
}

#Preview {
    MenuCocktailEntryRow(
        entry: MenuCocktailEntry(
            id: UUID(),
            menuVersionID: UUID(),
            name: "Garden Margarita",
            description: "Reposado, basil, lime, agave",
            priceText: "$15",
            sortOrder: 0,
            ocrConfidence: 0.8,
            isManuallyEdited: false,
            cocktailID: nil,
            createdAt: Date()
        )
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
