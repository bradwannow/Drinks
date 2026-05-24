import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    searchField
                        .fadeInOnAppear()

                    if viewModel.query.isEmpty {
                        categoriesSection
                            .fadeInOnAppear(delay: 0.05)

                        seasonalSection
                            .fadeInOnAppear(delay: 0.1)
                    }

                    resultsSection
                        .fadeInOnAppear(delay: 0.15)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
            .screenBackground()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .detailNavigation()
        }
    }

    private var searchField: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textTertiary)

            TextField("Bars, cocktails, neighborhoods…", text: $viewModel.query)
                .foregroundStyle(AppColors.textPrimary)
                .focused($isSearchFocused)

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .fill(AppColors.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                        .strokeBorder(
                            isSearchFocused ? AppColors.accent.opacity(0.4) : AppColors.surfaceHighlight.opacity(0.5),
                            lineWidth: 1
                        )
                }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Browse", subtitle: "Find your vibe")

            FlowLayout(spacing: AppSpacing.sm) {
                ForEach(viewModel.categories, id: \.self) { category in
                    CategoryChip(title: category)
                }
            }
        }
    }

    private var seasonalSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Seasonal Drinks",
                subtitle: "Rotating menus this month"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.seasonalCocktails) { cocktail in
                        NavigationLink(value: cocktail) {
                            SeasonalCocktailChip(cocktail: cocktail)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: viewModel.query.isEmpty ? "Popular Near You" : "Results",
                subtitle: viewModel.query.isEmpty ? "Top-rated spots" : nil
            )

            VStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.filteredBars) { bar in
                    NavigationLink(value: bar) {
                        BarCard(bar: bar, style: .wide)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct CategoryChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background {
                Capsule()
                    .fill(AppColors.surface)
                    .overlay {
                        Capsule()
                            .strokeBorder(AppColors.surfaceHighlight.opacity(0.6), lineWidth: 0.5)
                    }
            }
    }
}

private struct SeasonalCocktailChip: View {
    let cocktail: Cocktail

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            AsyncImageView(
                url: cocktail.imageURL,
                cornerRadius: AppSpacing.sm,
                showGradientOverlay: true
            )
            .frame(width: 140, height: 100)

            Text(cocktail.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)

            Text(cocktail.barName)
                .captionStyle()
        }
        .frame(width: 140)
    }
}

/// Simple horizontal flow layout for category chips.
private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> ArrangementResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            sizes.append(size)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return ArrangementResult(
            size: CGSize(width: maxWidth, height: y + rowHeight),
            positions: positions,
            sizes: sizes
        )
    }

    private struct ArrangementResult {
        let size: CGSize
        let positions: [CGPoint]
        let sizes: [CGSize]
    }
}

#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
