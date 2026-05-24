import Foundation
import Supabase

final class DatabaseService {
    static let shared = DatabaseService()

    private enum Table {
        static let bars = "bars"
        static let cocktails = "cocktails"
        static let happyHours = "happy_hours"
        static let profiles = "profiles"
        static let savedBars = "saved_bars"
        static let savedCocktails = "saved_cocktails"
    }

    private let manager: SupabaseManager
    private let auth: AuthService
    private var referenceCoordinate: Coordinate

    init(
        manager: SupabaseManager = .shared,
        auth: AuthService = .shared,
        referenceCoordinate: Coordinate = .defaultReference
    ) {
        self.manager = manager
        self.auth = auth
        self.referenceCoordinate = referenceCoordinate
    }

    func fetchFeaturedBars() async throws -> [Bar] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.BarRow] = try await client
            .from(Table.bars)
            .select()
            .or("is_featured.eq.true,is_trending.eq.true")
            .order("rating", ascending: false)
            .execute()
            .value

        return rows.map { $0.toBar(relativeTo: referenceCoordinate) }
    }

    func fetchTrendingCocktails() async throws -> [Cocktail] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.CocktailRow] = try await client
            .from(Table.cocktails)
            .select("*, bar_cocktails(bars(name))")
            .or("is_trending.eq.true,is_featured.eq.true")
            .order("is_featured", ascending: false)
            .execute()
            .value

        return rows.compactMap { $0.toCocktail() }
    }

    func fetchHappyHours() async throws -> [HappyHour] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.HappyHourRow] = try await client
            .from(Table.happyHours)
            .select("*, bars(name, neighborhood, image_url)")
            .order("created_at")
            .execute()
            .value

        return rows.compactMap { $0.toHappyHour() }
    }

    func fetchNearbyBars(limit: Int = 5) async throws -> [Bar] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.BarRow] = try await client
            .from(Table.bars)
            .select()
            .execute()
            .value

        return rows
            .map { $0.toBar(relativeTo: referenceCoordinate) }
            .sorted { $0.distanceMiles < $1.distanceMiles }
            .prefix(limit)
            .map { $0 }
    }

    func fetchCurrentProfile() async throws -> Profile {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        let row: DatabaseRecords.ProfileRow = try await client
            .from(Table.profiles)
            .select()
            .eq("id", value: userID)
            .single()
            .execute()
            .value

        return row.toProfile()
    }

    func updateProfile(displayName: String? = nil, username: String? = nil, avatarURL: String? = nil) async throws -> Profile {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        let update = ProfileUpdate(
            displayName: displayName?.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username?.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarURL: avatarURL
        )

        let row: DatabaseRecords.ProfileRow = try await client
            .from(Table.profiles)
            .update(update)
            .eq("id", value: userID)
            .select()
            .single()
            .execute()
            .value

        return row.toProfile()
    }

    func saveBar(_ barID: UUID) async throws {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        try await client
            .from(Table.savedBars)
            .insert(SavedBarInsert(userID: userID, barID: barID))
            .execute()
    }

    func saveCocktail(_ cocktailID: UUID) async throws {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        try await client
            .from(Table.savedCocktails)
            .insert(SavedCocktailInsert(userID: userID, cocktailID: cocktailID))
            .execute()
    }

    func unsaveBar(_ barID: UUID) async throws {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        try await client
            .from(Table.savedBars)
            .delete()
            .eq("user_id", value: userID)
            .eq("bar_id", value: barID)
            .execute()
    }

    func unsaveCocktail(_ cocktailID: UUID) async throws {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        try await client
            .from(Table.savedCocktails)
            .delete()
            .eq("user_id", value: userID)
            .eq("cocktail_id", value: cocktailID)
            .execute()
    }

    func fetchBar(id: UUID) async throws -> Bar {
        let client = try manager.requireClient()
        let row: DatabaseRecords.BarRow = try await client
            .from(Table.bars)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        return row.toBar(relativeTo: referenceCoordinate)
    }

    func fetchCocktail(id: UUID) async throws -> Cocktail {
        let client = try manager.requireClient()
        let row: DatabaseRecords.CocktailRow = try await client
            .from(Table.cocktails)
            .select("*, bar_cocktails(bars(name))")
            .eq("id", value: id)
            .single()
            .execute()
            .value

        guard let cocktail = row.toCocktail() else {
            throw NetworkError.notFound
        }

        return cocktail
    }

    func fetchBarMenuCocktails(forBar barID: UUID, barName: String) async throws -> [BarMenuCocktail] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.BarCocktailRow] = try await client
            .from("bar_cocktails")
            .select("is_signature, cocktails(*)")
            .eq("bar_id", value: barID)
            .execute()
            .value

        return rows.compactMap { $0.toBarMenuCocktail(barName: barName) }
    }

    func fetchHappyHours(forBar barID: UUID) async throws -> [HappyHour] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.HappyHourRow] = try await client
            .from(Table.happyHours)
            .select("*, bars(name, neighborhood, image_url)")
            .eq("bar_id", value: barID)
            .order("created_at")
            .execute()
            .value

        return rows.compactMap { $0.toHappyHour() }
    }

    func fetchRelatedCocktails(for cocktailID: UUID, spirit: String, limit: Int = 6) async throws -> [Cocktail] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.CocktailRow] = try await client
            .from(Table.cocktails)
            .select("*, bar_cocktails(bars(name))")
            .eq("spirit", value: spirit)
            .neq("id", value: cocktailID)
            .limit(limit)
            .execute()
            .value

        return rows.compactMap { $0.toCocktail() }
    }

    func fetchSavedBarIDs() async throws -> Set<UUID> {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        let rows: [DatabaseRecords.SavedBarIDRow] = try await client
            .from(Table.savedBars)
            .select("bar_id")
            .eq("user_id", value: userID)
            .execute()
            .value

        return Set(rows.map(\.barID))
    }

    func fetchSavedCocktailIDs() async throws -> Set<UUID> {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        let rows: [DatabaseRecords.SavedCocktailIDRow] = try await client
            .from(Table.savedCocktails)
            .select("cocktail_id")
            .eq("user_id", value: userID)
            .execute()
            .value

        return Set(rows.map(\.cocktailID))
    }

    func fetchSavedBars() async throws -> [Bar] {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        let rows: [DatabaseRecords.SavedBarJoinRow] = try await client
            .from(Table.savedBars)
            .select("bars(*)")
            .eq("user_id", value: userID)
            .order("created_at", ascending: false)
            .execute()
            .value

        return rows.compactMap { $0.toBar(relativeTo: referenceCoordinate) }
    }

    func fetchSavedCocktails() async throws -> [Cocktail] {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        let rows: [DatabaseRecords.SavedCocktailJoinRow] = try await client
            .from(Table.savedCocktails)
            .select("cocktails(*, bar_cocktails(bars(name)))")
            .eq("user_id", value: userID)
            .order("created_at", ascending: false)
            .execute()
            .value

        return rows.compactMap { $0.toCocktail() }
    }

    // MARK: - Search & Discovery

    func search(
        query: String,
        filters: SearchFilters,
        savedBarIDs: Set<UUID>,
        savedCocktailIDs: Set<UUID>,
        limit: Int = 20
    ) async throws -> SearchResults {
        async let happyHourBarIDs = fetchActiveHappyHourBarIDs()

        let activeHappyHourBarIDs = try await happyHourBarIDs
        let cocktailIDsInNeighborhood: Set<UUID>?
        if let neighborhood = filters.neighborhood {
            cocktailIDsInNeighborhood = try await fetchCocktailIDs(inNeighborhood: neighborhood)
        } else {
            cocktailIDsInNeighborhood = nil
        }

        async let barsTask = searchBars(
            query: query,
            filters: filters,
            savedBarIDs: savedBarIDs,
            happyHourBarIDs: activeHappyHourBarIDs,
            limit: limit
        )
        async let cocktailsTask = searchCocktails(
            query: query,
            filters: filters,
            savedCocktailIDs: savedCocktailIDs,
            cocktailIDsInNeighborhood: cocktailIDsInNeighborhood,
            limit: limit
        )
        async let neighborhoodsTask = searchNeighborhoods(matching: query, limit: 6)
        async let spiritsTask = searchSpirits(matching: query, limit: 6)

        let (bars, cocktails, neighborhoods, spirits) = try await (
            barsTask,
            cocktailsTask,
            neighborhoodsTask,
            spiritsTask
        )

        return SearchResults(
            bars: bars,
            cocktails: cocktails,
            neighborhoods: neighborhoods,
            spirits: spirits
        )
    }

    func fetchRecommendedCocktails(limit: Int = 8) async throws -> [Cocktail] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.CocktailRow] = try await client
            .from(Table.cocktails)
            .select("*, bar_cocktails(bars(name))")
            .or("is_trending.eq.true,is_featured.eq.true")
            .order("is_featured", ascending: false)
            .limit(limit)
            .execute()
            .value

        return rows.compactMap { $0.toCocktail() }
    }

    func fetchSeasonalCocktails(limit: Int = 8) async throws -> [Cocktail] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.CocktailRow] = try await client
            .from(Table.cocktails)
            .select("*, bar_cocktails(bars(name))")
            .eq("is_seasonal", value: true)
            .limit(limit)
            .execute()
            .value

        return rows.compactMap { $0.toCocktail() }
    }

    func fetchSpiritCategories() async throws -> [SpiritCategory] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.SpiritGroupRow] = try await client
            .from(Table.cocktails)
            .select("spirit, image_url")
            .execute()
            .value

        var grouped: [String: (count: Int, imageURL: URL)] = [:]
        for row in rows {
            if var existing = grouped[row.spirit] {
                existing.count += 1
                grouped[row.spirit] = existing
            } else {
                grouped[row.spirit] = (1, row.imageURL)
            }
        }

        return grouped
            .map { SpiritCategory(name: $0.key, cocktailCount: $0.value.count, imageURL: $0.value.imageURL) }
            .sorted { $0.cocktailCount > $1.cocktailCount }
    }

    func fetchNeighborhoodCategories() async throws -> [NeighborhoodCategory] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.NeighborhoodGroupRow] = try await client
            .from(Table.bars)
            .select("neighborhood, image_url")
            .execute()
            .value

        var grouped: [String: (count: Int, imageURL: URL)] = [:]
        for row in rows {
            if var existing = grouped[row.neighborhood] {
                existing.count += 1
                grouped[row.neighborhood] = existing
            } else {
                grouped[row.neighborhood] = (1, row.imageURL)
            }
        }

        return grouped
            .map { NeighborhoodCategory(name: $0.key, barCount: $0.value.count, imageURL: $0.value.imageURL) }
            .sorted { $0.barCount > $1.barCount }
    }

    func fetchAvailableSpirits() async throws -> [String] {
        try await fetchSpiritCategories().map(\.name).sorted()
    }

    func fetchAvailableNeighborhoods() async throws -> [String] {
        try await fetchNeighborhoodCategories().map(\.name).sorted()
    }

    func fetchActiveHappyHourBarIDs() async throws -> Set<UUID> {
        let hours = try await fetchHappyHours()
        return Set(hours.filter { HappyHourUtility.isActiveNow($0) }.map(\.barID))
    }

    private func searchBars(
        query: String,
        filters: SearchFilters,
        savedBarIDs: Set<UUID>,
        happyHourBarIDs: Set<UUID>,
        limit: Int
    ) async throws -> [Bar] {
        let client = try manager.requireClient()
        var request = client.from(Table.bars).select()

        if !query.isEmpty {
            let pattern = ilikePattern(query)
            request = request.or("name.ilike.\(pattern),neighborhood.ilike.\(pattern),tagline.ilike.\(pattern)")
        }

        if let neighborhood = filters.neighborhood {
            request = request.eq("neighborhood", value: neighborhood)
        }

        let rows: [DatabaseRecords.BarRow] = try await request
            .order("rating", ascending: false)
            .limit(limit * 2)
            .execute()
            .value

        var bars = rows.map { $0.toBar(relativeTo: referenceCoordinate) }

        if filters.happyHourNow {
            bars = bars.filter { happyHourBarIDs.contains($0.id) }
        }

        if filters.savedOnly {
            bars = bars.filter { savedBarIDs.contains($0.id) }
        }

        return Array(bars.prefix(limit))
    }

    private func searchCocktails(
        query: String,
        filters: SearchFilters,
        savedCocktailIDs: Set<UUID>,
        cocktailIDsInNeighborhood: Set<UUID>?,
        limit: Int
    ) async throws -> [Cocktail] {
        let client = try manager.requireClient()
        var request = client.from(Table.cocktails).select("*, bar_cocktails(bars(name))")

        if !query.isEmpty {
            let pattern = ilikePattern(query)
            request = request.or("name.ilike.\(pattern),description.ilike.\(pattern),spirit.ilike.\(pattern)")
        }

        if let spirit = filters.spirit {
            request = request.eq("spirit", value: spirit)
        }

        if filters.featuredOnly {
            request = request.eq("is_featured", value: true)
        }

        if filters.seasonalOnly {
            request = request.eq("is_seasonal", value: true)
        }

        let rows: [DatabaseRecords.CocktailRow] = try await request
            .order("is_featured", ascending: false)
            .limit(limit * 2)
            .execute()
            .value

        var cocktails = rows.compactMap { $0.toCocktail() }

        if let cocktailIDsInNeighborhood {
            cocktails = cocktails.filter { cocktailIDsInNeighborhood.contains($0.id) }
        }

        if filters.savedOnly {
            cocktails = cocktails.filter { savedCocktailIDs.contains($0.id) }
        }

        return Array(cocktails.prefix(limit))
    }

    private func searchNeighborhoods(matching query: String, limit: Int) async throws -> [String] {
        guard !query.isEmpty else { return [] }

        let client = try manager.requireClient()
        let pattern = ilikePattern(query)
        let rows: [DatabaseRecords.NeighborhoodNameRow] = try await client
            .from(Table.bars)
            .select("neighborhood")
            .ilike("neighborhood", pattern: pattern)
            .limit(limit * 3)
            .execute()
            .value

        var seen = Set<String>()
        return rows.map(\.neighborhood).filter { seen.insert($0).inserted }
    }

    private func searchSpirits(matching query: String, limit: Int) async throws -> [String] {
        guard !query.isEmpty else { return [] }

        let client = try manager.requireClient()
        let pattern = ilikePattern(query)
        let rows: [DatabaseRecords.SpiritNameRow] = try await client
            .from(Table.cocktails)
            .select("spirit")
            .ilike("spirit", pattern: pattern)
            .limit(limit * 3)
            .execute()
            .value

        var seen = Set<String>()
        return rows.map(\.spirit).filter { seen.insert($0).inserted }
    }

    private func fetchCocktailIDs(inNeighborhood neighborhood: String) async throws -> Set<UUID> {
        let client = try manager.requireClient()
        let barRows: [DatabaseRecords.BarIDRow] = try await client
            .from(Table.bars)
            .select("id")
            .eq("neighborhood", value: neighborhood)
            .execute()
            .value

        let barIDs = barRows.map(\.id)
        guard !barIDs.isEmpty else { return [] }

        let linkRows: [DatabaseRecords.BarCocktailLinkRow] = try await client
            .from("bar_cocktails")
            .select("cocktail_id")
            .in("bar_id", values: barIDs)
            .execute()
            .value

        return Set(linkRows.map(\.cocktailID))
    }

    private func ilikePattern(_ query: String) -> String {
        let escaped = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "%", with: "\\%")
            .replacingOccurrences(of: "_", with: "\\_")
        return "%\(escaped)%"
    }
}
