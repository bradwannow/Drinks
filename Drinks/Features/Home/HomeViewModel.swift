import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var featuredCocktail: Cocktail?
    @Published private(set) var trendingBars: [Bar] = []
    @Published private(set) var happyHours: [HappyHour] = []
    @Published private(set) var nearbyBars: [Bar] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let database: DatabaseService

    init(database: DatabaseService = .shared) {
        self.database = database
    }

    func load() async {
        await refresh()
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            async let featuredBarsTask = database.fetchFeaturedBars()
            async let trendingCocktailsTask = database.fetchTrendingCocktails()
            async let happyHoursTask = database.fetchHappyHours()
            async let nearbyBarsTask = database.fetchNearbyBars()

            let (bars, cocktails, hours, nearby) = try await (
                featuredBarsTask,
                trendingCocktailsTask,
                happyHoursTask,
                nearbyBarsTask
            )

            trendingBars = bars
            featuredCocktail = cocktails.first(where: \.isFeatured) ?? cocktails.first
            happyHours = hours
            nearbyBars = nearby
        } catch {
            errorMessage = NetworkError.map(error).errorDescription
        }

        isLoading = false
    }

    var hasLoadedContent: Bool {
        featuredCocktail != nil || !trendingBars.isEmpty || !happyHours.isEmpty || !nearbyBars.isEmpty
    }

    var shouldShowContentSections: Bool {
        hasLoadedContent || (errorMessage == nil && !isLoading)
    }
}
