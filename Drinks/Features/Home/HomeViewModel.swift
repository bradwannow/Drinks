import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var featuredCocktail: Cocktail
    @Published private(set) var trendingBars: [Bar]
    @Published private(set) var happyHours: [HappyHour]
    @Published private(set) var nearbyBars: [Bar]
    @Published private(set) var isLoading = false

    init(
        featuredCocktail: Cocktail = MockDataService.featuredCocktail,
        trendingBars: [Bar] = MockDataService.trendingBars,
        happyHours: [HappyHour] = MockDataService.happyHours,
        nearbyBars: [Bar] = MockDataService.nearbyBars
    ) {
        self.featuredCocktail = featuredCocktail
        self.trendingBars = trendingBars
        self.happyHours = happyHours
        self.nearbyBars = nearbyBars
    }

    func refresh() async {
        isLoading = true
        try? await Task.sleep(for: .milliseconds(400))
        featuredCocktail = MockDataService.featuredCocktail
        trendingBars = MockDataService.trendingBars
        happyHours = MockDataService.happyHours
        nearbyBars = MockDataService.nearbyBars
        isLoading = false
    }
}
