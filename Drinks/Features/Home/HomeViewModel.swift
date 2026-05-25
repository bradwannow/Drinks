import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var featuredCocktail: Cocktail?
    @Published private(set) var activityFeed: [ActivityFeedEntry] = []
    @Published private(set) var menusUpdatedTonight: [MenuDiscoveryItem] = []
    @Published private(set) var recentlyUpdatedMenus: [MenuDiscoveryItem] = []
    @Published private(set) var newSeasonalMenus: [MenuDiscoveryItem] = []
    @Published private(set) var recentlyAdded: [Cocktail] = []
    @Published private(set) var trendingTonight: [Cocktail] = []
    @Published private(set) var activeHappyHours: [HappyHour] = []
    @Published private(set) var seasonalNow: [Cocktail] = []
    @Published private(set) var trendingBars: [Bar] = []
    @Published private(set) var nearbyBars: [Bar] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let database: DatabaseService
    private let menuService: MenuService

    init(database: DatabaseService = .shared, menuService: MenuService = .shared) {
        self.database = database
        self.menuService = menuService
    }

    func load() async {
        await refresh()
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            async let activityTask = database.fetchActivityFeed()
            async let featuredBarsTask = database.fetchFeaturedBars()
            async let trendingCocktailsTask = database.fetchTrendingCocktails()
            async let recentlyAddedTask = database.fetchRecentlyAddedCocktails()
            async let trendingTonightTask = database.fetchTrendingTonightCocktails()
            async let activeHappyHoursTask = database.fetchActiveHappyHours()
            async let seasonalTask = database.fetchSeasonalCocktails()
            async let nearbyBarsTask = database.fetchNearbyBars()
            async let menusTonightTask = fetchMenusSafely { try await menuService.fetchMenusUpdatedTonight() }
            async let recentMenusTask = fetchMenusSafely { try await menuService.fetchRecentlyUpdatedMenus() }
            async let seasonalMenusTask = fetchMenusSafely { try await menuService.fetchNewSeasonalMenus() }

            let (
                activityItems,
                bars,
                cocktails,
                recent,
                trending,
                activeHours,
                seasonal,
                nearby,
                tonightMenus,
                updatedMenus,
                seasonalMenus
            ) = try await (
                activityTask,
                featuredBarsTask,
                trendingCocktailsTask,
                recentlyAddedTask,
                trendingTonightTask,
                activeHappyHoursTask,
                seasonalTask,
                nearbyBarsTask,
                menusTonightTask,
                recentMenusTask,
                seasonalMenusTask
            )

            trendingBars = bars
            featuredCocktail = cocktails.first(where: \.isFeatured) ?? cocktails.first
            recentlyAdded = recent
            trendingTonight = trending
            activeHappyHours = activeHours
            seasonalNow = seasonal
            nearbyBars = nearby
            menusUpdatedTonight = tonightMenus
            recentlyUpdatedMenus = updatedMenus
            newSeasonalMenus = seasonalMenus
            activityFeed = try await resolveActivityFeed(activityItems)
        } catch {
            errorMessage = NetworkError.map(error).errorDescription
        }

        isLoading = false
    }

    var hasLoadedContent: Bool {
        featuredCocktail != nil
            || !activityFeed.isEmpty
            || !menusUpdatedTonight.isEmpty
            || !recentlyUpdatedMenus.isEmpty
            || !newSeasonalMenus.isEmpty
            || !recentlyAdded.isEmpty
            || !trendingTonight.isEmpty
            || !activeHappyHours.isEmpty
            || !seasonalNow.isEmpty
            || !trendingBars.isEmpty
            || !nearbyBars.isEmpty
    }

    var shouldShowContentSections: Bool {
        hasLoadedContent || (errorMessage == nil && !isLoading)
    }

    private func resolveActivityFeed(_ items: [ActivityItem]) async throws -> [ActivityFeedEntry] {
        let cocktailIDs = Array(Set(items.compactMap(\.cocktailID)))
        let barIDs = Array(Set(items.compactMap(\.barID)))

        async let cocktailsTask = database.fetchCocktails(ids: cocktailIDs)
        async let barsTask = database.fetchBars(ids: barIDs)

        let (cocktails, bars) = try await (cocktailsTask, barsTask)
        let cocktailMap = Dictionary(uniqueKeysWithValues: cocktails.map { ($0.id, $0) })
        let barMap = Dictionary(uniqueKeysWithValues: bars.map { ($0.id, $0) })

        return items.map { item in
            ActivityFeedEntry(
                item: item,
                cocktail: item.cocktailID.flatMap { cocktailMap[$0] },
                bar: item.barID.flatMap { barMap[$0] }
            )
        }
    }

    private func fetchMenusSafely(_ fetch: () async throws -> [MenuDiscoveryItem]) async -> [MenuDiscoveryItem] {
        do {
            return try await fetch()
        } catch {
            return []
        }
    }
}
