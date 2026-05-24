import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var filters = SearchFilters()

    @Published private(set) var results = SearchResults()
    @Published private(set) var recentSearches: [String] = []
    @Published private(set) var recommendedCocktails: [Cocktail] = []
    @Published private(set) var spiritCategories: [SpiritCategory] = []
    @Published private(set) var neighborhoodCategories: [NeighborhoodCategory] = []
    @Published private(set) var featuredCollections: [FeaturedCollection] = []
    @Published private(set) var availableSpirits: [String] = []
    @Published private(set) var availableNeighborhoods: [String] = []

    @Published private(set) var isLoadingDiscovery = false
    @Published private(set) var isSearching = false
    @Published private(set) var errorMessage: String?

    private let database: DatabaseService
    private let recentSearchStore: RecentSearchStore
    private let saveStore: SaveStore
    private var searchTask: Task<Void, Never>?
    private var searchGeneration = 0

    init(
        database: DatabaseService = .shared,
        recentSearchStore: RecentSearchStore = .shared,
        saveStore: SaveStore = .shared
    ) {
        self.database = database
        self.recentSearchStore = recentSearchStore
        self.saveStore = saveStore
        self.recentSearches = recentSearchStore.load()
    }

    var isShowingResults: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || filters.isActive
    }

    var trendingSearches: [String] {
        TrendingSearches.curated
    }

    func loadDiscovery() async {
        guard !isLoadingDiscovery else { return }

        isLoadingDiscovery = true
        errorMessage = nil

        do {
            async let recommendedTask = database.fetchRecommendedCocktails()
            async let spiritsTask = database.fetchSpiritCategories()
            async let neighborhoodsTask = database.fetchNeighborhoodCategories()
            async let availableSpiritsTask = database.fetchAvailableSpirits()
            async let availableNeighborhoodsTask = database.fetchAvailableNeighborhoods()
            async let seasonalTask = database.fetchSeasonalCocktails(limit: 4)

            let (recommended, spirits, neighborhoods, spiritsList, neighborhoodsList, seasonal) = try await (
                recommendedTask,
                spiritsTask,
                neighborhoodsTask,
                availableSpiritsTask,
                availableNeighborhoodsTask,
                seasonalTask
            )

            recommendedCocktails = recommended
            spiritCategories = spirits
            neighborhoodCategories = neighborhoods
            availableSpirits = spiritsList
            availableNeighborhoods = neighborhoodsList
            featuredCollections = buildFeaturedCollections(
                recommended: recommended,
                seasonal: seasonal,
                neighborhoods: neighborhoods
            )
        } catch {
            errorMessage = NetworkError.map(error).errorDescription
        }

        isLoadingDiscovery = false
    }

    func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    func performSearchImmediately() async {
        searchTask?.cancel()
        await performSearch()
    }

    func selectRecentSearch(_ term: String) {
        query = term
        scheduleSearch()
    }

    func selectTrendingSearch(_ term: String) {
        query = term
        scheduleSearch()
    }

    func selectSpirit(_ spirit: String) {
        filters.applySpirit(spirit)
        Task { await performSearchImmediately() }
    }

    func selectNeighborhood(_ neighborhood: String) {
        filters.applyNeighborhood(neighborhood)
        Task { await performSearchImmediately() }
    }

    func applyCollection(_ collection: FeaturedCollection) {
        query = collection.query
        filters = collection.filters
        Task { await performSearchImmediately() }
    }

    func recordCurrentSearchIfNeeded() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !results.isEmpty else { return }
        recentSearchStore.add(trimmed)
        recentSearches = recentSearchStore.load()
    }

    func removeRecentSearch(_ term: String) {
        recentSearchStore.remove(term)
        recentSearches = recentSearchStore.load()
    }

    func clearRecentSearches() {
        recentSearchStore.clear()
        recentSearches = []
    }

    private func performSearch() async {
        guard isShowingResults else {
            results = SearchResults()
            isSearching = false
            return
        }

        searchGeneration += 1
        let generation = searchGeneration
        isSearching = true
        errorMessage = nil

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let searchResults = try await database.search(
                query: trimmedQuery,
                filters: filters,
                savedBarIDs: saveStore.savedBarIDs,
                savedCocktailIDs: saveStore.savedCocktailIDs
            )

            guard generation == searchGeneration else { return }
            results = searchResults
            recordCurrentSearchIfNeeded()
        } catch {
            guard generation == searchGeneration else { return }
            errorMessage = NetworkError.map(error).errorDescription
            results = SearchResults()
        }

        isSearching = false
    }

    private func buildFeaturedCollections(
        recommended: [Cocktail],
        seasonal: [Cocktail],
        neighborhoods: [NeighborhoodCategory]
    ) -> [FeaturedCollection] {
        var collections: [FeaturedCollection] = []

        if let featured = recommended.first(where: \.isFeatured) ?? recommended.first {
            collections.append(
                FeaturedCollection(
                    id: "editors-picks",
                    title: "Editor's Picks",
                    subtitle: "Featured pours worth the trip",
                    icon: "sparkles",
                    imageURL: featured.imageURL,
                    filters: SearchFilters(featuredOnly: true)
                )
            )
        }

        if let seasonalCocktail = seasonal.first {
            collections.append(
                FeaturedCollection(
                    id: "seasonal",
                    title: "Season's Best",
                    subtitle: "Rotating menus for right now",
                    icon: "leaf.fill",
                    imageURL: seasonalCocktail.imageURL,
                    filters: SearchFilters(seasonalOnly: true)
                )
            )
        }

        collections.append(
            FeaturedCollection(
                id: "happy-hour",
                title: "Happy Hour Now",
                subtitle: "Deals happening tonight",
                icon: "clock.fill",
                imageURL: neighborhoods.first?.imageURL,
                filters: SearchFilters(happyHourNow: true)
            )
        )

        if let neighborhood = neighborhoods.first {
            collections.append(
                FeaturedCollection(
                    id: "neighborhood-\(neighborhood.id)",
                    title: neighborhood.name,
                    subtitle: "\(neighborhood.barCount) bars to explore",
                    icon: "mappin.circle.fill",
                    imageURL: neighborhood.imageURL,
                    filters: SearchFilters(neighborhood: neighborhood.name)
                )
            )
        }

        return collections
    }
}
