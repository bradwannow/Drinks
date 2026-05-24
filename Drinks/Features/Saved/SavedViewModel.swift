import Combine
import Foundation

@MainActor
final class SavedViewModel: ObservableObject {
    @Published private(set) var savedBars: [Bar] = []
    @Published private(set) var savedCocktails: [Cocktail] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let database: DatabaseService
    private var cancellables = Set<AnyCancellable>()

    init(database: DatabaseService = .shared, saveStore: SaveStore = .shared) {
        self.database = database

        saveStore.$revision
            .dropFirst()
            .sink { [weak self] _ in
                Task { await self?.refresh() }
            }
            .store(in: &cancellables)
    }

    var isEmpty: Bool {
        !isLoading && savedBars.isEmpty && savedCocktails.isEmpty && errorMessage == nil
    }

    func load() async {
        await refresh()
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil

        do {
            async let barsTask = database.fetchSavedBars()
            async let cocktailsTask = database.fetchSavedCocktails()

            savedBars = try await barsTask
            savedCocktails = try await cocktailsTask
        } catch {
            errorMessage = NetworkError.map(error).errorDescription
        }

        isLoading = false
    }
}
