import SwiftUI

struct MenuDiffSection: View {
    let comparison: MenuComparison

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Menu Changes",
                subtitle: "Compared to the previous version"
            )

            if !comparison.hasChanges {
                PourCard {
                    Label("No cocktail changes detected", systemImage: "arrow.triangle.2.circlepath")
                        .captionStyle()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: AppSpacing.sm) {
                    if !comparison.added.isEmpty {
                        changeGroup(title: "Newly Added", icon: "plus.circle.fill", tint: AppColors.accent, names: comparison.added)
                    }
                    if !comparison.seasonalReturns.isEmpty {
                        changeGroup(title: "Seasonal Returns", icon: "leaf.arrow.circlepath", tint: AppColors.accentMuted, names: comparison.seasonalReturns)
                    }
                    if !comparison.removed.isEmpty {
                        changeGroup(title: "Removed", icon: "minus.circle.fill", tint: AppColors.accentSecondary, names: comparison.removed)
                    }
                }
            }
        }
    }

    private func changeGroup(title: String, icon: String, tint: Color, names: [String]) -> some View {
        PourCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Label(title, systemImage: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tint)

                FlowLayout(spacing: AppSpacing.xs) {
                    ForEach(names, id: \.self) { name in
                        Text(name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xxs)
                            .background(AppColors.backgroundElevated)
                            .clipShape(Capsule())
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    MenuDiffSection(
        comparison: MenuComparison(
            added: ["Smoked Negroni", "Garden Spritz"],
            removed: ["Old Fashioned"],
            seasonalReturns: ["Pumpkin Spice Martini"]
        )
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
