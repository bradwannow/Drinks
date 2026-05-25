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

    private enum RPC {
        static let confirmMenu = "confirm_menu"
        static let reportOutdated = "report_menu_outdated"
        static let viewerState = "menu_viewer_state"
    }

    private let manager: SupabaseManager
    private let auth: AuthService
    private let storage: StorageService
    private let referenceCoordinate: Coordinate

    init(
        manager: SupabaseManager = .shared,
        auth: AuthService = .shared,
        storage: StorageService = .shared,
        referenceCoordinate: Coordinate = .defaultReference
    ) {
        self.manager = manager
        self.auth = auth
        self.storage = storage
        self.referenceCoordinate = referenceCoordinate
    }

    func fetchBarMenuArchive(forBar barID: UUID) async throws -> BarMenuArchive {
        let versions = try await fetchMenuVersions(forBar: barID)
        let currentVersion = versions.first(where: \.isCurrent)
        let previousMenus = versions.filter { !$0.isCurrent }
        let seasonalRotations = versions.filter { $0.isSeasonal && !$0.isCurrent }

        var currentDetail: MenuVersionDetail?
        var menuComparison: MenuComparison?
        var recentlyAdded: [MenuCocktailEntry] = []

        if let currentVersion {
            currentDetail = try await fetchMenuVersionDetail(id: currentVersion.id)

            if let previous = previousMenus.first {
                let previousDetail = try await fetchMenuVersionDetail(id: previous.id)
                let historicalCocktails = try await fetchHistoricalSeasonalCocktails(
                    forBar: barID,
                    excludingVersionIDs: [currentVersion.id, previous.id]
                )
                let comparison = MenuComparisonUtility.compare(
                    current: currentDetail?.cocktails ?? [],
                    previous: previousDetail.cocktails,
                    historicalSeasonal: historicalCocktails
                )
                menuComparison = comparison
                let addedNames = Set(
                    (comparison.added + comparison.seasonalReturns)
                        .map { $0.lowercased() }
                )
                recentlyAdded = (currentDetail?.cocktails ?? []).filter {
                    addedNames.contains($0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
                }
                if recentlyAdded.count > 6 {
                    recentlyAdded = Array(recentlyAdded.prefix(6))
                }
                if var detail = currentDetail {
                    detail.comparison = comparison
                    currentDetail = detail
                }
            }
        }

        return BarMenuArchive(
            currentMenu: currentDetail,
            previousMenus: previousMenus,
            recentlyAddedCocktails: recentlyAdded,
            seasonalRotations: seasonalRotations,
            menuComparison: menuComparison
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
        async let detailTask: DatabaseRecords.MenuVersionDetailRow = client
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

        async let viewerStateTask = fetchViewerState(for: id)

        let row = try await detailTask
        let viewerState = await viewerStateTask
        var detail = try row.toMenuVersionDetail(storage: storage)
        detail.viewerState = viewerState
        return detail
    }

    func fetchRecentlyUpdatedMenus(limit: Int = 8) async throws -> [MenuDiscoveryItem] {
        try await fetchDiscoveryMenus(
            limit: limit,
            filter: { _ in true }
        )
    }

    func fetchMenusUpdatedTonight(limit: Int = 6) async throws -> [MenuDiscoveryItem] {
        let cutoff = Date().addingTimeInterval(-24 * 60 * 60)
        return try await fetchDiscoveryMenus(limit: limit) { $0.uploadedAt >= cutoff }
    }

    func fetchNewSeasonalMenus(limit: Int = 6) async throws -> [MenuDiscoveryItem] {
        try await fetchDiscoveryMenus(limit: limit) { row in
            row.seasonLabel != nil || row.seasonMonth != nil
        }
    }

    func confirmMenu(versionID: UUID) async throws -> MenuVersion {
        let client = try manager.requireClient()
        guard try await auth.currentSession()?.user.id != nil else {
            throw NetworkError.unauthorized
        }

        let result: DatabaseRecords.MenuValidationResultRow = try await client
            .rpc(RPC.confirmMenu, params: MenuVersionIDParam(menuVersionID: versionID))
            .execute()
            .value

        var detail = try await fetchMenuVersionDetail(id: versionID)
        if let count = result.confirmationCount {
            detail = updatedDetail(detail, confirmationCount: count, confidenceScore: result.confidenceScore, isOutdated: result.isOutdated ?? false)
        }
        return detail.version
    }

    func reportMenuOutdated(versionID: UUID) async throws -> MenuVersion {
        let client = try manager.requireClient()
        guard try await auth.currentSession()?.user.id != nil else {
            throw NetworkError.unauthorized
        }

        let result: DatabaseRecords.MenuValidationResultRow = try await client
            .rpc(RPC.reportOutdated, params: MenuVersionIDParam(menuVersionID: versionID))
            .execute()
            .value

        var detail = try await fetchMenuVersionDetail(id: versionID)
        detail = updatedDetail(
            detail,
            confirmationCount: detail.version.confirmationCount,
            confidenceScore: detail.version.confidenceScore,
            isOutdated: result.isOutdated ?? detail.version.isOutdated
        )
        return detail.version
    }

    func fetchMenuComparison(currentVersionID: UUID, previousVersionID: UUID) async throws -> MenuComparison {
        async let currentTask = fetchMenuVersionDetail(id: currentVersionID)
        async let previousTask = fetchMenuVersionDetail(id: previousVersionID)
        let (current, previous) = try await (currentTask, previousTask)
        return MenuComparisonUtility.compare(
            current: current.cocktails,
            previous: previous.cocktails
        )
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

    private func fetchDiscoveryMenus(
        limit: Int,
        filter: (DatabaseRecords.MenuDiscoveryRow) -> Bool
    ) async throws -> [MenuDiscoveryItem] {
        let client = try manager.requireClient()
        let rows: [DatabaseRecords.MenuDiscoveryRow] = try await client
            .from(Table.menuVersions)
            .select("""
                *,
                menu_images(id, storage_path, sort_order),
                menu_cocktails(id),
                profiles(display_name, username),
                bars(*)
            """)
            .eq("is_current", value: true)
            .eq("is_outdated", value: false)
            .order("uploaded_at", ascending: false)
            .limit(limit * 2)
            .execute()
            .value

        return rows
            .filter(filter)
            .prefix(limit)
            .enumerated()
            .compactMap { index, row in
                row.toDiscoveryItem(
                    versionNumber: rows.count - index,
                    storage: storage,
                    coordinate: referenceCoordinate
                )
            }
    }

    private func fetchHistoricalSeasonalCocktails(
        forBar barID: UUID,
        excludingVersionIDs: [UUID]
    ) async throws -> [MenuCocktailEntry] {
        let versions = try await fetchMenuVersions(forBar: barID)
        let seasonalVersions = versions.filter {
            $0.isSeasonal && !excludingVersionIDs.contains($0.id)
        }

        var entries: [MenuCocktailEntry] = []
        for version in seasonalVersions.prefix(4) {
            let detail = try await fetchMenuVersionDetail(id: version.id)
            entries.append(contentsOf: detail.cocktails)
        }
        return entries
    }

    private func fetchViewerState(for menuVersionID: UUID) async -> MenuViewerState {
        do {
            let client = try manager.requireClient()
            let row: DatabaseRecords.MenuViewerStateRow = try await client
                .rpc(RPC.viewerState, params: MenuVersionIDParam(menuVersionID: menuVersionID))
                .execute()
                .value
            return row.toViewerState
        } catch {
            return .anonymous
        }
    }

    private func updatedDetail(
        _ detail: MenuVersionDetail,
        confirmationCount: Int,
        confidenceScore: Float?,
        isOutdated: Bool
    ) -> MenuVersionDetail {
        let version = detail.version
        let updatedVersion = MenuVersion(
            id: version.id,
            menuID: version.menuID,
            barID: version.barID,
            contributorID: version.contributorID,
            contributorName: version.contributorName,
            seasonLabel: version.seasonLabel,
            seasonMonth: version.seasonMonth,
            isCurrent: version.isCurrent,
            notes: version.notes,
            ocrStatus: version.ocrStatus,
            uploadedAt: version.uploadedAt,
            createdAt: version.createdAt,
            versionNumber: version.versionNumber,
            imageCount: version.imageCount,
            cocktailCount: version.cocktailCount,
            coverImageURL: version.coverImageURL,
            confirmationCount: confirmationCount,
            confidenceScore: confidenceScore ?? version.confidenceScore,
            isOutdated: isOutdated
        )
        return MenuVersionDetail(
            version: updatedVersion,
            images: detail.images,
            cocktails: detail.cocktails,
            comparison: detail.comparison,
            viewerState: detail.viewerState
        )
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

private struct MenuVersionIDParam: Encodable {
    let menuVersionID: UUID

    enum CodingKeys: String, CodingKey {
        case menuVersionID = "p_menu_version_id"
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
