import Foundation

struct Cocktail: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let description: String
    let imageURL: URL
    let barName: String
    let spirit: String
    let isSeasonal: Bool
    let isFeatured: Bool
    let isTrending: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        imageURL: URL,
        barName: String,
        spirit: String,
        isSeasonal: Bool = false,
        isFeatured: Bool = false,
        isTrending: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.barName = barName
        self.spirit = spirit
        self.isSeasonal = isSeasonal
        self.isFeatured = isFeatured
        self.isTrending = isTrending
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case imageURL = "image_url"
        case barName = "bar_name"
        case spirit
        case isSeasonal = "is_seasonal"
        case isFeatured = "is_featured"
        case isTrending = "is_trending"
    }
}
