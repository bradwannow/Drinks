import Combine
import Foundation

@MainActor
final class SaveStore: ObservableObject {
    static let shared = SaveStore()

    @Published private(set) var savedBarIDs: Set<UUID> = []
    @Published private(set) var savedCocktailIDs: Set<UUID> = []
    @Published private(set) var revision = 0

    private let database: DatabaseService

    init(database: DatabaseService = .shared) {
        self.database = database
    }

    func load() async {
        do {
            async let barIDs = database.fetchSavedBarIDs()
            async let cocktailIDs = database.fetchSavedCocktailIDs()
            savedBarIDs = try await barIDs
            savedCocktailIDs = try await cocktailIDs
        } catch {
            savedBarIDs = []
            savedCocktailIDs = []
        }
    }

    func reset() {
        savedBarIDs = []
        savedCocktailIDs = []
        revision = 0
    }

    func isBarSaved(_ barID: UUID) -> Bool {
        savedBarIDs.contains(barID)
    }

    func isCocktailSaved(_ cocktailID: UUID) -> Bool {
        savedCocktailIDs.contains(cocktailID)
    }

    func toggleBar(_ barID: UUID) async {
        let wasSaved = savedBarIDs.contains(barID)

        if wasSaved {
            savedBarIDs.remove(barID)
        } else {
            savedBarIDs.insert(barID)
            HapticFeedback.light()
        }

        do {
            if wasSaved {
                try await database.unsaveBar(barID)
            } else {
                try await database.saveBar(barID)
            }
            revision += 1
        } catch {
            if wasSaved {
                savedBarIDs.insert(barID)
            } else {
                savedBarIDs.remove(barID)
            }
        }
    }

    func toggleCocktail(_ cocktailID: UUID) async {
        let wasSaved = savedCocktailIDs.contains(cocktailID)

        if wasSaved {
            savedCocktailIDs.remove(cocktailID)
        } else {
            savedCocktailIDs.insert(cocktailID)
            HapticFeedback.light()
        }

        do {
            if wasSaved {
                try await database.unsaveCocktail(cocktailID)
            } else {
                try await database.saveCocktail(cocktailID)
            }
            revision += 1
        } catch {
            if wasSaved {
                savedCocktailIDs.insert(cocktailID)
            } else {
                savedCocktailIDs.remove(cocktailID)
            }
        }
    }
}
