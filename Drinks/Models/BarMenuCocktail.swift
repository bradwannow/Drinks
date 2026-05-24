import Foundation

struct BarMenuCocktail: Identifiable, Hashable {
    var id: UUID { cocktail.id }
    let cocktail: Cocktail
    let isSignature: Bool
}
