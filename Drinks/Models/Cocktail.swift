import Foundation

struct Cocktail: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let imageURL: URL
    let barName: String
    let spirit: String
    let isSeasonal: Bool
    let isFeatured: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        imageURL: URL,
        barName: String,
        spirit: String,
        isSeasonal: Bool = false,
        isFeatured: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.barName = barName
        self.spirit = spirit
        self.isSeasonal = isSeasonal
        self.isFeatured = isFeatured
    }
}
