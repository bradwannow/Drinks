import Foundation

struct Bar: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let neighborhood: String
    let tagline: String
    let rating: Double
    let imageURL: URL
    let latitude: Double
    let longitude: Double
    let isTrending: Bool
    let isFeatured: Bool
    let isNewlyOpened: Bool
    let createdAt: Date?
    let referenceCoordinate: Coordinate

    init(
        id: UUID = UUID(),
        name: String,
        neighborhood: String,
        tagline: String,
        rating: Double,
        imageURL: URL,
        latitude: Double,
        longitude: Double,
        isTrending: Bool = false,
        isFeatured: Bool = false,
        isNewlyOpened: Bool = false,
        createdAt: Date? = nil,
        referenceCoordinate: Coordinate = .defaultReference
    ) {
        self.id = id
        self.name = name
        self.neighborhood = neighborhood
        self.tagline = tagline
        self.rating = rating
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.isTrending = isTrending
        self.isFeatured = isFeatured
        self.isNewlyOpened = isNewlyOpened
        self.createdAt = createdAt
        self.referenceCoordinate = referenceCoordinate
    }

    var distanceMiles: Double {
        LocationUtility.distanceMiles(
            from: referenceCoordinate,
            to: Coordinate(latitude: latitude, longitude: longitude)
        )
    }

    var formattedDistance: String {
        String(format: "%.1f mi", distanceMiles)
    }

    var formattedRating: String {
        String(format: "%.1f", rating)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case neighborhood
        case tagline
        case rating
        case imageURL = "image_url"
        case latitude
        case longitude
        case isTrending = "is_trending"
        case isFeatured = "is_featured"
        case isNewlyOpened = "is_newly_opened"
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        neighborhood = try container.decode(String.self, forKey: .neighborhood)
        tagline = try container.decode(String.self, forKey: .tagline)
        rating = try container.decode(Double.self, forKey: .rating)
        imageURL = try container.decode(URL.self, forKey: .imageURL)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        isTrending = try container.decode(Bool.self, forKey: .isTrending)
        isFeatured = try container.decode(Bool.self, forKey: .isFeatured)
        isNewlyOpened = try container.decodeIfPresent(Bool.self, forKey: .isNewlyOpened) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        referenceCoordinate = .defaultReference
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(neighborhood, forKey: .neighborhood)
        try container.encode(tagline, forKey: .tagline)
        try container.encode(rating, forKey: .rating)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(isTrending, forKey: .isTrending)
        try container.encode(isFeatured, forKey: .isFeatured)
        try container.encode(isNewlyOpened, forKey: .isNewlyOpened)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

