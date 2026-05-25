import Foundation

enum MenuOCRStatus: String, Codable, Hashable {
    case pending
    case processing
    case completed
    case failed
    case skipped
}

struct MenuVersion: Identifiable, Hashable {
    let id: UUID
    let menuID: UUID
    let barID: UUID
    let contributorID: UUID?
    let contributorName: String?
    let seasonLabel: String?
    let seasonMonth: Int?
    let isCurrent: Bool
    let notes: String?
    let ocrStatus: MenuOCRStatus
    let uploadedAt: Date
    let createdAt: Date
    let versionNumber: Int
    let imageCount: Int
    let cocktailCount: Int
    let coverImageURL: URL?

    var displayTitle: String {
        if let seasonLabel, !seasonLabel.isEmpty {
            return seasonLabel
        }
        if let seasonMonth {
            return MenuSeasonUtility.monthName(seasonMonth)
        }
        return "Menu v\(versionNumber)"
    }

    var displaySubtitle: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let relative = formatter.localizedString(for: uploadedAt, relativeTo: Date())
        if isCurrent {
            return "Current · \(relative)"
        }
        return "Archived · \(relative)"
    }

    var isSeasonal: Bool {
        seasonLabel != nil || seasonMonth != nil
    }
}

struct MenuImage: Identifiable, Hashable {
    let id: UUID
    let menuVersionID: UUID
    let storagePath: String
    let imageURL: URL
    let sortOrder: Int
    let ocrRawText: String?
}

struct MenuCocktailEntry: Identifiable, Hashable {
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

    var hasLowConfidence: Bool {
        guard let ocrConfidence else { return false }
        return ocrConfidence < 0.6 && !isManuallyEdited
    }
}

struct MenuVersionDetail: Identifiable, Hashable {
    let version: MenuVersion
    let images: [MenuImage]
    let cocktails: [MenuCocktailEntry]

    var id: UUID { version.id }
}

struct BarMenuArchive: Hashable {
    let currentMenu: MenuVersionDetail?
    let previousMenus: [MenuVersion]
    let recentlyAddedCocktails: [MenuCocktailEntry]
    let seasonalRotations: [MenuVersion]
}

struct DraftMenuCocktail: Identifiable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var priceText: String?
    var ocrConfidence: Float?
    var isManuallyEdited: Bool

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        priceText: String? = nil,
        ocrConfidence: Float? = nil,
        isManuallyEdited: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.priceText = priceText
        self.ocrConfidence = ocrConfidence
        self.isManuallyEdited = isManuallyEdited
    }

    init(from entry: MenuCocktailEntry) {
        id = entry.id
        name = entry.name
        description = entry.description
        priceText = entry.priceText
        ocrConfidence = entry.ocrConfidence
        isManuallyEdited = entry.isManuallyEdited
    }
}

enum MenuSeasonUtility {
    static let monthNames = Calendar.current.monthSymbols

    static func monthName(_ month: Int) -> String {
        guard month >= 1, month <= 12 else { return "Seasonal Menu" }
        return monthNames[month - 1]
    }

    static func currentMonth() -> Int {
        Calendar.current.component(.month, from: Date())
    }

    static func currentSeasonLabel() -> String {
        let month = currentMonth()
        switch month {
        case 3...5: return "Spring"
        case 6...8: return "Summer"
        case 9...11: return "Fall"
        default: return "Winter"
        }
    }

    static let seasonPresets = ["Spring", "Summer", "Fall", "Winter", "Holiday", "Limited Run"]
}
