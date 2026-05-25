import Foundation
import UIKit

enum MenuOCRStatus: String, Codable, Hashable {
    case pending
    case processing
    case completed
    case failed
    case skipped
}

enum MenuFreshnessLevel: Hashable {
    case updatedTonight
    case updatedThisWeek
    case current
    case stale
    case outdated

    var badge: FreshnessBadge? {
        switch self {
        case .updatedTonight: return .updatedTonight
        case .updatedThisWeek: return .updatedThisWeek
        case .stale, .outdated: return .staleMenu
        case .current: return nil
        }
    }
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
    let confirmationCount: Int
    let confidenceScore: Float
    let isOutdated: Bool

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

    func freshnessLevel(at date: Date = Date()) -> MenuFreshnessLevel {
        if isOutdated { return .outdated }
        return FreshnessUtility.menuFreshnessLevel(uploadedAt: uploadedAt, at: date)
    }

    func freshnessBadges(at date: Date = Date()) -> [FreshnessBadge] {
        FreshnessUtility.badges(for: self, at: date)
    }

    var lastUpdatedLabel: String {
        FreshnessUtility.menuLastUpdatedLabel(for: uploadedAt)
    }

    var confidenceLabel: String {
        switch confidenceScore {
        case 0.7...: return "High confidence"
        case 0.4..<0.7: return "Moderate confidence"
        default: return confirmationCount > 0 ? "Building trust" : "Awaiting confirmation"
        }
    }

    var isCommunityVerified: Bool {
        confidenceScore >= 0.5 && confirmationCount >= 2
    }
}

struct MenuViewerState: Hashable {
    let hasConfirmed: Bool
    let hasReportedOutdated: Bool

    static let anonymous = MenuViewerState(hasConfirmed: false, hasReportedOutdated: false)
}

struct MenuDiscoveryItem: Identifiable, Hashable {
    let version: MenuVersion
    let bar: Bar

    var id: UUID { version.id }
}

enum MenuCocktailChangeKind: Hashable {
    case added
    case removed
    case seasonalReturn
}

struct MenuCocktailChange: Identifiable, Hashable {
    let name: String
    let kind: MenuCocktailChangeKind

    var id: String { "\(kind)-\(name)" }
}

struct MenuComparison: Hashable {
    let added: [String]
    let removed: [String]
    let seasonalReturns: [String]

    var hasChanges: Bool {
        !added.isEmpty || !removed.isEmpty || !seasonalReturns.isEmpty
    }

    var allChanges: [MenuCocktailChange] {
        added.map { MenuCocktailChange(name: $0, kind: .added) }
            + removed.map { MenuCocktailChange(name: $0, kind: .removed) }
            + seasonalReturns.map { MenuCocktailChange(name: $0, kind: .seasonalReturn) }
    }
}

struct DraftMenuImage: Identifiable {
    let id: UUID
    let image: UIImage
    let data: Data

    init(id: UUID = UUID(), image: UIImage, data: Data) {
        self.id = id
        self.image = image
        self.data = data
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
    var comparison: MenuComparison?
    var viewerState: MenuViewerState

    var id: UUID { version.id }

    init(
        version: MenuVersion,
        images: [MenuImage],
        cocktails: [MenuCocktailEntry],
        comparison: MenuComparison? = nil,
        viewerState: MenuViewerState = .anonymous
    ) {
        self.version = version
        self.images = images
        self.cocktails = cocktails
        self.comparison = comparison
        self.viewerState = viewerState
    }
}

struct BarMenuArchive: Hashable {
    let currentMenu: MenuVersionDetail?
    let previousMenus: [MenuVersion]
    let recentlyAddedCocktails: [MenuCocktailEntry]
    let seasonalRotations: [MenuVersion]
    let menuComparison: MenuComparison?
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
