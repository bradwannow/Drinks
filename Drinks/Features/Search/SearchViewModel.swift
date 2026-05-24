import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var categories: [String]
    @Published private(set) var recentBars: [Bar]
    @Published private(set) var seasonalCocktails: [Cocktail]

    init(
        categories: [String] = MockDataService.searchCategories,
        recentBars: [Bar] = MockDataService.trendingBars,
        seasonalCocktails: [Cocktail] = MockDataService.cocktails.filter(\.isSeasonal)
    ) {
        self.categories = categories
        self.recentBars = recentBars
        self.seasonalCocktails = seasonalCocktails
    }

    var filteredBars: [Bar] {
        guard !query.isEmpty else { return recentBars }
        return recentBars.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.neighborhood.localizedCaseInsensitiveContains(query) ||
            $0.tagline.localizedCaseInsensitiveContains(query)
        }
    }
}
