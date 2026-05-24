import Foundation

@MainActor
final class SavedViewModel: ObservableObject {
    @Published private(set) var savedBars: [Bar]
    @Published private(set) var savedCocktails: [Cocktail]

    init(
        savedBars: [Bar] = MockDataService.savedBars,
        savedCocktails: [Cocktail] = MockDataService.savedCocktails
    ) {
        self.savedBars = savedBars
        self.savedCocktails = savedCocktails
    }

    var isEmpty: Bool {
        savedBars.isEmpty && savedCocktails.isEmpty
    }
}
