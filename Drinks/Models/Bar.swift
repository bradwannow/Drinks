import Foundation

struct Bar: Identifiable, Hashable {
    let id: UUID
    let name: String
    let neighborhood: String
    let tagline: String
    let rating: Double
    let imageURL: URL
    let distanceMiles: Double
    let isTrending: Bool

    init(
        id: UUID = UUID(),
        name: String,
        neighborhood: String,
        tagline: String,
        rating: Double,
        imageURL: URL,
        distanceMiles: Double,
        isTrending: Bool = false
    ) {
        self.id = id
        self.name = name
        self.neighborhood = neighborhood
        self.tagline = tagline
        self.rating = rating
        self.imageURL = imageURL
        self.distanceMiles = distanceMiles
        self.isTrending = isTrending
    }

    var formattedDistance: String {
        String(format: "%.1f mi", distanceMiles)
    }

    var formattedRating: String {
        String(format: "%.1f", rating)
    }
}
