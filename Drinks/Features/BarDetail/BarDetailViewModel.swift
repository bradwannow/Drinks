import Foundation

struct BarDetailContent: Equatable {
    let bar: Bar
    let cocktails: [BarMenuCocktail]
    let happyHours: [HappyHour]
    let updates: [BarUpdate]
    let menuArchive: BarMenuArchive

    static func == (lhs: BarDetailContent, rhs: BarDetailContent) -> Bool {
        lhs.bar == rhs.bar
            && lhs.cocktails == rhs.cocktails
            && lhs.happyHours == rhs.happyHours
            && lhs.updates == rhs.updates
            && lhs.menuArchive.currentMenu?.id == rhs.menuArchive.currentMenu?.id
            && lhs.menuArchive.previousMenus.map(\.id) == rhs.menuArchive.previousMenus.map(\.id)
            && lhs.menuArchive.menuComparison == rhs.menuArchive.menuComparison
    }
}

@MainActor
final class BarDetailViewModel: ObservableObject {
    @Published private(set) var loadState: LoadingState<BarDetailContent> = .idle

    private let barID: UUID
    private let previewBar: Bar?
    private let database: DatabaseService
    private let menuService: MenuService

    init(
        bar: Bar,
        database: DatabaseService = .shared,
        menuService: MenuService = .shared
    ) {
        self.barID = bar.id
        self.previewBar = bar
        self.database = database
        self.menuService = menuService
    }

    init(
        barID: UUID,
        database: DatabaseService = .shared,
        menuService: MenuService = .shared
    ) {
        self.barID = barID
        self.previewBar = nil
        self.database = database
        self.menuService = menuService
    }

    var displayBar: Bar? {
        loadState.value?.bar ?? previewBar
    }

    func load() async {
        loadState = .loading

        do {
            let bar: Bar
            if let previewBar {
                bar = previewBar
            } else {
                bar = try await database.fetchBar(id: barID)
            }

            async let cocktailsTask = database.fetchBarMenuCocktails(forBar: bar.id, barName: bar.name)
            async let happyHoursTask = database.fetchHappyHours(forBar: bar.id)
            async let updatesTask = database.fetchBarUpdates(forBar: bar.id)
            async let menuArchiveTask = fetchMenuArchiveSafely(forBar: bar.id)

            let content = BarDetailContent(
                bar: bar,
                cocktails: try await cocktailsTask,
                happyHours: try await happyHoursTask,
                updates: try await updatesTask,
                menuArchive: await menuArchiveTask
            )
            loadState = .loaded(content)
        } catch {
            loadState = .failed(NetworkError.map(error))
        }
    }

    private func fetchMenuArchiveSafely(forBar barID: UUID) async -> BarMenuArchive {
        do {
            return try await menuService.fetchBarMenuArchive(forBar: barID)
        } catch {
            return BarMenuArchive(
                currentMenu: nil,
                previousMenus: [],
                recentlyAddedCocktails: [],
                seasonalRotations: [],
                menuComparison: nil
            )
        }
    }
}
