import Foundation
import Supabase

final class MenuService {
    static let shared = MenuService()

    private enum Table {
        static let menus = "menus"
        static let menuVersions = "menu_versions"
        static let menuImages = "menu_images"
        static let menuCocktails = "menu_cocktails"
    }

    private let manager: SupabaseManager
    private let auth: AuthService
    private let storage: StorageService

    init(
        manager: SupabaseManager = .shared,
        auth: AuthService = .shared,
        storage: StorageService = .shared
    ) {
        self.manager = manager
        self.auth = auth
        self.storage = storage
    }

    func fetchBarMenuArchive(forBar barID: UUID) async throws -> BarMenuArchive {
        async let versionsTask = fetchMenuVersions(forBar: barID)
        let versions = try await versionsTask

        let currentVersion = versions.first(where: \.isCurrent)
        let currentDetail: MenuVersionDetail?
        if let currentVersion {
            currentDetail = try await fetchMenuVersionDetail(id: currentVersion.id)
        } else {
            currentDetail = nil
        }

        let previousMenus = versions.filter { !$0.isCurrent }
        let seasonalRotations = versions.filter { $0.isSeasonal && !$0.isCurrent }

        let recentlyAdded: [MenuCocktailEntry]
        if let currentDetail {
            recentlyAdded = Array(currentDetail.cocktails.prefix(6))
        } else if let latest = versions.first {
            let detail = try await fetchMenuVersionDetail(id: latest.id)
            recentlyAdded = Array(detail.cocktails.prefix(6))
        } else {
            recentlyAdded = []
        }

        return BarMenuArchive(
            currentMenu: currentDetail,
            previousMenus: previousMenus,
            recentlyAddedCocktails: recentlyAdded,
            seasonalRotations: seasonalRotations
        )
    }

    func fetchMenuVersions(forBar barID: UUID) async throws -> [MenuVersion] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.MenuVersionRow] = try await client
            .from(Table.menuVersions)
            .select("""
                *,
                menu_images(id, storage_path, sort_order),
                menu_cocktails(id),
                profiles(display_name, username)
            """)
            .eq("bar_id", value: barID)
            .order("uploaded_at", ascending: false)
            .execute()
            .value

        return rows.enumerated().map { index, row in
            row.toMenuVersion(versionNumber: rows.count - index, storage: storage)
        }
    }

    func fetchMenuVersionDetail(id: UUID) async throws -> MenuVersionDetail {
        let client = try manager.requireClient()
        let row: DatabaseRecords.MenuVersionDetailRow = try await client
            .from(Table.menuVersions)
            .select("""
                *,
                menu_images(*),
                menu_cocktails(*),
                profiles(display_name, username)
            """)
            .eq("id", value: id)
            .single()
            .execute()
            .value

        return try row.toMenuVersionDetail(storage: storage)
    }

    func createMenuUpload(
        barID: UUID,
        imageData: [Data],
        ocrTexts: [String],
        cocktails: [DraftMenuCocktail],
        seasonLabel: String?,
        seasonMonth: Int?,
        isCurrent: Bool,
        notes: String?
    ) async throws -> MenuVersionDetail {
        let client = try manager.requireClient()
        guard let userID = try await auth.currentSession()?.user.id else {
            throw NetworkError.unauthorized
        }

        let menuID = try await ensureMenu(forBar: barID)

        let versionInsert = MenuVersionInsert(
            menuID: menuID,
            barID: barID,
            contributorID: userID,
            seasonLabel: seasonLabel?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            seasonMonth: seasonMonth,
            isCurrent: isCurrent,
            notes: notes?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            ocrStatus: cocktails.isEmpty ? MenuOCRStatus.skipped.rawValue : MenuOCRStatus.completed.rawValue
        )

        let versionRow: DatabaseRecords.MenuVersionRow = try await client
            .from(Table.menuVersions)
            .insert(versionInsert)
            .select()
            .single()
            .execute()
            .value

        let versionID = versionRow.id

        for (index, data) in imageData.enumerated() {
            let upload = try await storage.uploadMenuImage(
                data: data,
                barID: barID,
                menuVersionID: versionID,
                sortOrder: index
            )

            let imageInsert = MenuImageInsert(
                menuVersionID: versionID,
                storagePath: upload.path,
                sortOrder: index,
                ocrRawText: ocrTexts.indices.contains(index) ? ocrTexts[index].nilIfEmpty : nil
            )

            try await client
                .from(Table.menuImages)
                .insert(imageInsert)
                .execute()
        }

        if !cocktails.isEmpty {
            let cocktailInserts = cocktails.enumerated().map { index, cocktail in
                MenuCocktailInsert(
                    menuVersionID: versionID,
                    name: cocktail.name,
                    description: cocktail.description,
                    priceText: cocktail.priceText,
                    sortOrder: index,
                    ocrConfidence: cocktail.ocrConfidence,
                    isManuallyEdited: cocktail.isManuallyEdited
                )
            }

            try await client
                .from(Table.menuCocktails)
                .insert(cocktailInserts)
                .execute()
        }

        return try await fetchMenuVersionDetail(id: versionID)
    }

    func updateMenuCocktails(
        menuVersionID: UUID,
        cocktails: [DraftMenuCocktail]
    ) async throws {
        let client = try manager.requireClient()
        guard try await auth.currentSession()?.user.id != nil else {
            throw NetworkError.unauthorized
        }

        try await client
            .from(Table.menuCocktails)
            .delete()
            .eq("menu_version_id", value: menuVersionID)
            .execute()

        guard !cocktails.isEmpty else { return }

        let inserts = cocktails.enumerated().map { index, cocktail in
            MenuCocktailInsert(
                menuVersionID: menuVersionID,
                name: cocktail.name,
                description: cocktail.description,
                priceText: cocktail.priceText,
                sortOrder: index,
                ocrConfidence: cocktail.ocrConfidence,
                isManuallyEdited: cocktail.isManuallyEdited
            )
        }

        try await client
            .from(Table.menuCocktails)
            .insert(inserts)
            .execute()
    }

    private func ensureMenu(forBar barID: UUID) async throws -> UUID {
        let client = try manager.requireClient()

        let existing: [DatabaseRecords.MenuIDRow] = try await client
            .from(Table.menus)
            .select("id")
            .eq("bar_id", value: barID)
            .limit(1)
            .execute()
            .value

        if let menuID = existing.first?.id {
            return menuID
        }

        let created: DatabaseRecords.MenuIDRow = try await client
            .from(Table.menus)
            .insert(MenuContainerInsert(barID: barID))
            .select("id")
            .single()
            .execute()
            .value

        return created.id
    }
}

private struct MenuContainerInsert: Encodable {
    let barID: UUID

    enum CodingKeys: String, CodingKey {
        case barID = "bar_id"
    }
}

private struct MenuVersionInsert: Encodable {
    let menuID: UUID
    let barID: UUID
    let contributorID: UUID
    let seasonLabel: String?
    let seasonMonth: Int?
    let isCurrent: Bool
    let notes: String?
    let ocrStatus: String

    enum CodingKeys: String, CodingKey {
        case menuID = "menu_id"
        case barID = "bar_id"
        case contributorID = "contributor_id"
        case seasonLabel = "season_label"
        case seasonMonth = "season_month"
        case isCurrent = "is_current"
        case notes
        case ocrStatus = "ocr_status"
    }
}

private struct MenuImageInsert: Encodable {
    let menuVersionID: UUID
    let storagePath: String
    let sortOrder: Int
    let ocrRawText: String?

    enum CodingKeys: String, CodingKey {
        case menuVersionID = "menu_version_id"
        case storagePath = "storage_path"
        case sortOrder = "sort_order"
        case ocrRawText = "ocr_raw_text"
    }
}

private struct MenuCocktailInsert: Encodable {
    let menuVersionID: UUID
    let name: String
    let description: String
    let priceText: String?
    let sortOrder: Int
    let ocrConfidence: Float?
    let isManuallyEdited: Bool

    enum CodingKeys: String, CodingKey {
        case menuVersionID = "menu_version_id"
        case name, description
        case priceText = "price_text"
        case sortOrder = "sort_order"
        case ocrConfidence = "ocr_confidence"
        case isManuallyEdited = "is_manually_edited"
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
