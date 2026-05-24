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
}
