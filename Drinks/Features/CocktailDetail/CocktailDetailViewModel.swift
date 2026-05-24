import Foundation

struct CocktailDetailContent: Equatable {
    let cocktail: Cocktail
    let relatedCocktails: [Cocktail]
}

@MainActor
final class CocktailDetailViewModel: ObservableObject {
    @Published private(set) var loadState: LoadingState<CocktailDetailContent> = .idle

    private let cocktailID: UUID
    private let previewCocktail: Cocktail?
    private let database: DatabaseService

    init(cocktail: Cocktail, database: DatabaseService = .shared) {
        self.cocktailID = cocktail.id
        self.previewCocktail = cocktail
        self.database = database
    }

    init(cocktailID: UUID, database: DatabaseService = .shared) {
        self.cocktailID = cocktailID
        self.previewCocktail = nil
        self.database = database
    }

    var displayCocktail: Cocktail? {
        loadState.value?.cocktail ?? previewCocktail
    }

    func load() async {
        loadState = .loading

        do {
            let cocktail: Cocktail
            if let previewCocktail {
                cocktail = previewCocktail
            } else {
                cocktail = try await database.fetchCocktail(id: cocktailID)
            }

            let related = try await database.fetchRelatedCocktails(
                for: cocktail.id,
                spirit: cocktail.spirit
            )

            loadState = .loaded(
                CocktailDetailContent(cocktail: cocktail, relatedCocktails: related)
            )
        } catch {
            loadState = .failed(NetworkError.map(error))
        }
    }
}
