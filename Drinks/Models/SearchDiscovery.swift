import Foundation

struct SpiritCategory: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let cocktailCount: Int
    let imageURL: URL

    init(name: String, cocktailCount: Int, imageURL: URL) {
        self.id = name
        self.name = name
        self.cocktailCount = cocktailCount
        self.imageURL = imageURL
    }
}

struct NeighborhoodCategory: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let barCount: Int
    let imageURL: URL

    init(name: String, barCount: Int, imageURL: URL) {
        self.id = name
        self.name = name
        self.barCount = barCount
        self.imageURL = imageURL
    }
}

struct FeaturedCollection: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let imageURL: URL?
    let filters: SearchFilters
    let query: String

    init(
        id: String,
        title: String,
        subtitle: String,
        icon: String,
        imageURL: URL? = nil,
        filters: SearchFilters = SearchFilters(),
        query: String = ""
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.imageURL = imageURL
        self.filters = filters
        self.query = query
    }
}

enum TrendingSearches {
    static let curated = [
        "Gin",
        "Wicker Park",
        "Negroni",
        "Happy Hour",
        "West Loop",
        "Rum",
        "Logan Square",
        "Seasonal"
    ]
}
