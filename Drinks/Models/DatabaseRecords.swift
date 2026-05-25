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
        let isNewlyOpened: Bool
        let createdAt: Date?

        enum CodingKeys: String, CodingKey {
            case id, name, neighborhood, tagline, rating, latitude, longitude
            case imageURL = "image_url"
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
                isNewlyOpened: isNewlyOpened,
                createdAt: createdAt,
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
        let isLimitedTime: Bool
        let isStaffPick: Bool
        let createdAt: Date?
        let availableUntil: Date?
        let barCocktails: [BarCocktailJoin]?

        enum CodingKeys: String, CodingKey {
            case id, name, description, spirit
            case imageURL = "image_url"
            case isSeasonal = "is_seasonal"
            case isFeatured = "is_featured"
            case isTrending = "is_trending"
            case isLimitedTime = "is_limited_time"
            case isStaffPick = "is_staff_pick"
            case createdAt = "created_at"
            case availableUntil = "available_until"
            case barCocktails = "bar_cocktails"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            description = try container.decode(String.self, forKey: .description)
            imageURL = try container.decode(URL.self, forKey: .imageURL)
            spirit = try container.decode(String.self, forKey: .spirit)
            isSeasonal = try container.decode(Bool.self, forKey: .isSeasonal)
            isFeatured = try container.decode(Bool.self, forKey: .isFeatured)
            isTrending = try container.decode(Bool.self, forKey: .isTrending)
            isLimitedTime = try container.decodeIfPresent(Bool.self, forKey: .isLimitedTime) ?? false
            isStaffPick = try container.decodeIfPresent(Bool.self, forKey: .isStaffPick) ?? false
            createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
            availableUntil = try container.decodeIfPresent(Date.self, forKey: .availableUntil)
            barCocktails = try container.decodeIfPresent([BarCocktailJoin].self, forKey: .barCocktails)
        }

        struct BarCocktailJoin: Decodable {
            let bars: BarNameJoin?
        }

        struct BarNameJoin: Decodable {
            let name: String
        }

        func toCocktail() -> Cocktail? {
            guard let barName = barCocktails?.first?.bars?.name else { return nil }
            return toCocktail(barName: barName)
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
                isTrending: isTrending,
                isLimitedTime: isLimitedTime,
                isStaffPick: isStaffPick,
                createdAt: createdAt,
                availableUntil: availableUntil
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

            let cocktail = row.toCocktail(barName: barName)

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

    struct ActivityFeedRow: Decodable {
        let id: UUID
        let type: String
        let title: String
        let subtitle: String?
        let barID: UUID?
        let cocktailID: UUID?
        let imageURL: URL?
        let startsAt: Date?
        let endsAt: Date?
        let createdAt: Date

        enum CodingKeys: String, CodingKey {
            case id, type, title, subtitle
            case barID = "bar_id"
            case cocktailID = "cocktail_id"
            case imageURL = "image_url"
            case startsAt = "starts_at"
            case endsAt = "ends_at"
            case createdAt = "created_at"
        }

        func toActivityItem() -> ActivityItem? {
            guard let activityType = ActivityType(rawValue: type) else { return nil }
            return ActivityItem(
                id: id,
                type: activityType,
                title: title,
                subtitle: subtitle,
                barID: barID,
                cocktailID: cocktailID,
                imageURL: imageURL,
                startsAt: startsAt,
                endsAt: endsAt,
                createdAt: createdAt
            )
        }
    }

    struct BarUpdateRow: Decodable {
        let id: UUID
        let barID: UUID
        let type: String
        let title: String
        let description: String
        let cocktailID: UUID?
        let eventDate: String?
        let startsAt: Date?
        let endsAt: Date?
        let createdAt: Date

        enum CodingKeys: String, CodingKey {
            case id, type, title, description
            case barID = "bar_id"
            case cocktailID = "cocktail_id"
            case eventDate = "event_date"
            case startsAt = "starts_at"
            case endsAt = "ends_at"
            case createdAt = "created_at"
        }

        func toBarUpdate() -> BarUpdate? {
            guard let updateType = BarUpdateType(rawValue: type) else { return nil }
            let parsedEventDate = eventDate.flatMap { DatabaseRecords.parseDateOnly($0) }
            return BarUpdate(
                id: id,
                barID: barID,
                type: updateType,
                title: title,
                description: description,
                cocktailID: cocktailID,
                eventDate: parsedEventDate,
                startsAt: startsAt,
                endsAt: endsAt,
                createdAt: createdAt
            )
        }
    }

    struct NotificationPreferencesRow: Decodable {
        let savedBarCocktails: Bool
        let happyHourReminders: Bool
        let seasonalLaunches: Bool

        enum CodingKeys: String, CodingKey {
            case savedBarCocktails = "saved_bar_cocktails"
            case happyHourReminders = "happy_hour_reminders"
            case seasonalLaunches = "seasonal_launches"
        }

        func toPreferences() -> NotificationPreferences {
            NotificationPreferences(
                savedBarCocktails: savedBarCocktails,
                happyHourReminders: happyHourReminders,
                seasonalLaunches: seasonalLaunches
            )
        }
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

    struct MenuIDRow: Decodable {
        let id: UUID
    }

    struct MenuVersionRow: Decodable {
        let id: UUID
        let menuID: UUID
        let barID: UUID
        let contributorID: UUID?
        let seasonLabel: String?
        let seasonMonth: Int?
        let isCurrent: Bool
        let notes: String?
        let ocrStatus: String
        let uploadedAt: Date
        let createdAt: Date
        let menuImages: [MenuImageSummaryRow]?
        let menuCocktails: [MenuCocktailIDRow]?
        let profiles: ContributorJoin?

        enum CodingKeys: String, CodingKey {
            case id
            case menuID = "menu_id"
            case barID = "bar_id"
            case contributorID = "contributor_id"
            case seasonLabel = "season_label"
            case seasonMonth = "season_month"
            case isCurrent = "is_current"
            case notes
            case ocrStatus = "ocr_status"
            case uploadedAt = "uploaded_at"
            case createdAt = "created_at"
            case menuImages = "menu_images"
            case menuCocktails = "menu_cocktails"
            case profiles
        }

        struct MenuImageSummaryRow: Decodable {
            let id: UUID
            let storagePath: String
            let sortOrder: Int

            enum CodingKeys: String, CodingKey {
                case id
                case storagePath = "storage_path"
                case sortOrder = "sort_order"
            }
        }

        struct MenuCocktailIDRow: Decodable {
            let id: UUID
        }

        struct ContributorJoin: Decodable {
            let displayName: String?
            let username: String?

            enum CodingKeys: String, CodingKey {
                case displayName = "display_name"
                case username
            }

            var resolvedName: String? {
                displayName ?? username
            }
        }

        func toMenuVersion(versionNumber: Int, storage: StorageService) -> MenuVersion {
            let sortedImages = (menuImages ?? []).sorted { $0.sortOrder < $1.sortOrder }
            let coverURL = sortedImages.first.flatMap { try? storage.publicURL(forStoragePath: $0.storagePath) }

            return MenuVersion(
                id: id,
                menuID: menuID,
                barID: barID,
                contributorID: contributorID,
                contributorName: profiles?.resolvedName,
                seasonLabel: seasonLabel,
                seasonMonth: seasonMonth,
                isCurrent: isCurrent,
                notes: notes,
                ocrStatus: MenuOCRStatus(rawValue: ocrStatus) ?? .pending,
                uploadedAt: uploadedAt,
                createdAt: createdAt,
                versionNumber: versionNumber,
                imageCount: menuImages?.count ?? 0,
                cocktailCount: menuCocktails?.count ?? 0,
                coverImageURL: coverURL
            )
        }
    }

    struct MenuVersionDetailRow: Decodable {
        let id: UUID
        let menuID: UUID
        let barID: UUID
        let contributorID: UUID?
        let seasonLabel: String?
        let seasonMonth: Int?
        let isCurrent: Bool
        let notes: String?
        let ocrStatus: String
        let uploadedAt: Date
        let createdAt: Date
        let menuImages: [MenuImageRow]?
        let menuCocktails: [MenuCocktailRow]?
        let profiles: MenuVersionRow.ContributorJoin?

        enum CodingKeys: String, CodingKey {
            case id
            case menuID = "menu_id"
            case barID = "bar_id"
            case contributorID = "contributor_id"
            case seasonLabel = "season_label"
            case seasonMonth = "season_month"
            case isCurrent = "is_current"
            case notes
            case ocrStatus = "ocr_status"
            case uploadedAt = "uploaded_at"
            case createdAt = "created_at"
            case menuImages = "menu_images"
            case menuCocktails = "menu_cocktails"
            case profiles
        }

        func toMenuVersionDetail(storage: StorageService) throws -> MenuVersionDetail {
            let sortedImages = (menuImages ?? []).sorted { $0.sortOrder < $1.sortOrder }
            let images = try sortedImages.map { try $0.toMenuImage(storage: storage) }
            let cocktails = (menuCocktails ?? [])
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { $0.toMenuCocktailEntry() }

            let version = MenuVersion(
                id: id,
                menuID: menuID,
                barID: barID,
                contributorID: contributorID,
                contributorName: profiles?.resolvedName,
                seasonLabel: seasonLabel,
                seasonMonth: seasonMonth,
                isCurrent: isCurrent,
                notes: notes,
                ocrStatus: MenuOCRStatus(rawValue: ocrStatus) ?? .pending,
                uploadedAt: uploadedAt,
                createdAt: createdAt,
                versionNumber: 1,
                imageCount: images.count,
                cocktailCount: cocktails.count,
                coverImageURL: images.first?.imageURL
            )

            return MenuVersionDetail(version: version, images: images, cocktails: cocktails)
        }
    }

    struct MenuImageRow: Decodable {
        let id: UUID
        let menuVersionID: UUID
        let storagePath: String
        let sortOrder: Int
        let ocrRawText: String?

        enum CodingKeys: String, CodingKey {
            case id
            case menuVersionID = "menu_version_id"
            case storagePath = "storage_path"
            case sortOrder = "sort_order"
            case ocrRawText = "ocr_raw_text"
        }

        func toMenuImage(storage: StorageService) throws -> MenuImage {
            MenuImage(
                id: id,
                menuVersionID: menuVersionID,
                storagePath: storagePath,
                imageURL: try storage.publicURL(forStoragePath: storagePath),
                sortOrder: sortOrder,
                ocrRawText: ocrRawText
            )
        }
    }

    struct MenuCocktailRow: Decodable {
        let id: UUID
        let menuVersionID: UUID
        let name: String
        let description: String
        let priceText: String?
        let sortOrder: Int
        let ocrConfidence: Float?
        let isManuallyEdited: Bool
        let cocktailID: UUID?
        let createdAt: Date

        enum CodingKeys: String, CodingKey {
            case id, name, description
            case menuVersionID = "menu_version_id"
            case priceText = "price_text"
            case sortOrder = "sort_order"
            case ocrConfidence = "ocr_confidence"
            case isManuallyEdited = "is_manually_edited"
            case cocktailID = "cocktail_id"
            case createdAt = "created_at"
        }

        func toMenuCocktailEntry() -> MenuCocktailEntry {
            MenuCocktailEntry(
                id: id,
                menuVersionID: menuVersionID,
                name: name,
                description: description,
                priceText: priceText,
                sortOrder: sortOrder,
                ocrConfidence: ocrConfidence,
                isManuallyEdited: isManuallyEdited,
                cocktailID: cocktailID,
                createdAt: createdAt
            )
        }
    }

    static func parseDateOnly(_ value: String) -> Date? {
        dateOnlyFormatter.date(from: value)
    }

    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
