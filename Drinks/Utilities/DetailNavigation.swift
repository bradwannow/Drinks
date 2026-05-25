import SwiftUI

extension View {
    func detailNavigation() -> some View {
        navigationDestination(for: Bar.self) { bar in
            BarDetailView(bar: bar)
        }
        .navigationDestination(for: Cocktail.self) { cocktail in
            CocktailDetailView(cocktail: cocktail)
        }
        .navigationDestination(for: BarRoute.self) { route in
            BarDetailView(barID: route.id)
        }
        .navigationDestination(for: MenuVersionDetail.self) { detail in
            MenuDetailView(detail: detail)
        }
        .navigationDestination(for: MenuVersionRoute.self) { route in
            MenuDetailView(menuVersionID: route.id, previousVersionID: route.previousVersionID)
        }
    }
}
