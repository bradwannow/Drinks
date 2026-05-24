import Foundation

enum DatabaseRecords {
    struct BarRow: Decodable {
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

        enum CodingKeys: String, CodingKey {
            case id, name, neighborhood, tagline, rating, latitude, longitude
            case imageURL = "image_url"
            case isTrending = "is_trending"
            case isFeatured = "is_featured"
        }

        func toBar(relativeTo coordinate: Coordinate) -> Bar {
            Bar(
                id: id,
                name: name,
                neighborhood: neighborhood,
                tagline: tagline,
                rating: rating,
                imageURL: imageURL,
                latitude: latitude,
                longitude: longitude,
                isTrending: isTrending,
                isFeatured: isFeatured,
                referenceCoordinate: coordinate
            )
        }
    }

    struct CocktailRow: Decodable {
        let id: UUID
        let name: String
        let description: String
        let imageURL: URL
        let spirit: String
        let isSeasonal: Bool
        let isFeatured: Bool
        let isTrending: Bool
        let barCocktails: [BarCocktailJoin]?

        enum CodingKeys: String, CodingKey {
            case id, name, description, spirit
            case imageURL = "image_url"
            case isSeasonal = "is_seasonal"
            case isFeatured = "is_featured"
            case isTrending = "is_trending"
            case barCocktails = "bar_cocktails"
        }

        struct BarCocktailJoin: Decodable {
            let bars: BarNameJoin?
        }

        struct BarNameJoin: Decodable {
            let name: String
        }

        func toCocktail() -> Cocktail? {
            guard let barName = barCocktails?.first?.bars?.name else { return nil }

            return Cocktail(
                id: id,
                name: name,
                description: description,
                imageURL: imageURL,
                barName: barName,
                spirit: spirit,
                isSeasonal: isSeasonal,
                isFeatured: isFeatured,
                isTrending: isTrending
            )
        }

        func toCocktail(barName: String) -> Cocktail {
            Cocktail(
                id: id,
                name: name,
                description: description,
                imageURL: imageURL,
                barName: barName,
                spirit: spirit,
                isSeasonal: isSeasonal,
                isFeatured: isFeatured,
                isTrending: isTrending
            )
        }
    }

    struct HappyHourRow: Decodable {
        let id: UUID
        let barID: UUID
        let timeRange: String
        let dealDescription: String
        let daysActive: String
        let bars: BarJoin?

        enum CodingKeys: String, CodingKey {
            case id, bars
            case barID = "bar_id"
            case timeRange = "time_range"
            case dealDescription = "deal_description"
            case daysActive = "days_active"
        }

        struct BarJoin: Decodable {
            let name: String
            let neighborhood: String
            let imageURL: URL

            enum CodingKeys: String, CodingKey {
                case name, neighborhood
                case imageURL = "image_url"
            }
        }

        func toHappyHour() -> HappyHour? {
            guard let bar = bars else { return nil }

            return HappyHour(
                id: id,
                barID: barID,
                barName: bar.name,
                barImageURL: bar.imageURL,
                neighborhood: bar.neighborhood,
                timeRange: timeRange,
                dealDescription: dealDescription,
                daysActive: daysActive
            )
        }
    }

    struct BarCocktailRow: Decodable {
        let isSignature: Bool
        let cocktails: CocktailRow?

        enum CodingKeys: String, CodingKey {
            case cocktails
            case isSignature = "is_signature"
        }

        func toBarMenuCocktail(barName: String) -> BarMenuCocktail? {
            guard let row = cocktails else { return nil }

            let cocktail = Cocktail(
                id: row.id,
                name: row.name,
                description: row.description,
                imageURL: row.imageURL,
                barName: barName,
                spirit: row.spirit,
                isSeasonal: row.isSeasonal,
                isFeatured: row.isFeatured,
                isTrending: row.isTrending
            )

            return BarMenuCocktail(cocktail: cocktail, isSignature: isSignature)
        }
    }

    struct SavedBarJoinRow: Decodable {
        let bars: BarRow?

        func toBar(relativeTo coordinate: Coordinate) -> Bar? {
            bars?.toBar(relativeTo: coordinate)
        }
    }

    struct SavedCocktailJoinRow: Decodable {
        let cocktails: CocktailRow?

        func toCocktail() -> Cocktail? {
            cocktails?.toCocktail()
        }
    }

    struct SavedBarIDRow: Decodable {
        let barID: UUID

        enum CodingKeys: String, CodingKey {
            case barID = "bar_id"
        }
    }

    struct SavedCocktailIDRow: Decodable {
        let cocktailID: UUID

        enum CodingKeys: String, CodingKey {
            case cocktailID = "cocktail_id"
        }
    }

    struct BarCocktailLinkRow: Decodable {
        let cocktailID: UUID

        enum CodingKeys: String, CodingKey {
            case cocktailID = "cocktail_id"
        }
    }

    struct SpiritGroupRow: Decodable {
        let spirit: String
        let imageURL: URL

        enum CodingKeys: String, CodingKey {
            case spirit
            case imageURL = "image_url"
        }
    }

    struct NeighborhoodGroupRow: Decodable {
        let neighborhood: String
        let imageURL: URL

        enum CodingKeys: String, CodingKey {
            case neighborhood
            case imageURL = "image_url"
        }
    }

    struct BarIDRow: Decodable {
        let id: UUID
    }

    struct SpiritNameRow: Decodable {
        let spirit: String
    }

    struct NeighborhoodNameRow: Decodable {
        let neighborhood: String
    }

    struct ProfileRow: Decodable {
        let id: UUID
        let username: String?
        let displayName: String?
        let avatarURL: URL?
        let createdAt: Date
        let updatedAt: Date

        enum CodingKeys: String, CodingKey {
            case id, username
            case displayName = "display_name"
            case avatarURL = "avatar_url"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }

        func toProfile() -> Profile {
            Profile(
                id: id,
                username: username,
                displayName: displayName,
                avatarURL: avatarURL,
                createdAt: createdAt,
                updatedAt: updatedAt
            )
        }
    }
}
