import SwiftUI

extension View {
    func detailNavigation() -> some View {
        navigationDestination(for: Bar.self) { bar in
            BarDetailView(bar: bar)
        }
        .navigationDestination(for: Cocktail.self) { cocktail in
            CocktailDetailView(cocktail: cocktail)
        }
        .navigationDestination(for: UUID.self) { barID in
            BarDetailView(barID: barID)
        }
    }
}
