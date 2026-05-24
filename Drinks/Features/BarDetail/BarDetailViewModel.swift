import Foundation

struct BarDetailContent: Equatable {
    let bar: Bar
    let cocktails: [BarMenuCocktail]
    let happyHours: [HappyHour]
}

@MainActor
final class BarDetailViewModel: ObservableObject {
    @Published private(set) var loadState: LoadingState<BarDetailContent> = .idle

    private let barID: UUID
    private let previewBar: Bar?
    private let database: DatabaseService

    init(bar: Bar, database: DatabaseService = .shared) {
        self.barID = bar.id
        self.previewBar = bar
        self.database = database
    }

    init(barID: UUID, database: DatabaseService = .shared) {
        self.barID = barID
        self.previewBar = nil
        self.database = database
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

            let content = BarDetailContent(
                bar: bar,
                cocktails: try await cocktailsTask,
                happyHours: try await happyHoursTask
            )
            loadState = .loaded(content)
        } catch {
            loadState = .failed(NetworkError.map(error))
        }
    }
}
