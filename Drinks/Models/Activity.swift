import Foundation

enum ActivityType: String, Codable, CaseIterable {
    case newCocktail = "new_cocktail"
    case seasonalDrop = "seasonal_drop"
    case featuredCocktail = "featured_cocktail"
    case trendingBar = "trending_bar"
    case happyHourSoon = "happy_hour_soon"
    case newBar = "new_bar"

    var icon: String {
        switch self {
        case .newCocktail: return "plus.circle.fill"
        case .seasonalDrop: return "leaf.fill"
        case .featuredCocktail: return "sparkles"
        case .trendingBar: return "flame.fill"
        case .happyHourSoon: return "clock.badge.exclamationmark.fill"
        case .newBar: return "building.2.fill"
        }
    }

    var label: String {
        switch self {
        case .newCocktail: return "New"
        case .seasonalDrop: return "Seasonal"
        case .featuredCocktail: return "Featured"
        case .trendingBar: return "Trending"
        case .happyHourSoon: return "Soon"
        case .newBar: return "New Bar"
        }
    }
}

struct ActivityItem: Identifiable, Hashable {
    let id: UUID
    let type: ActivityType
    let title: String
    let subtitle: String?
    let barID: UUID?
    let cocktailID: UUID?
    let imageURL: URL?
    let startsAt: Date?
    let endsAt: Date?
    let createdAt: Date

    var navigationBarID: UUID? { barID }
    var navigationCocktailID: UUID? { cocktailID }
}

enum BarUpdateType: String, Codable, CaseIterable {
    case menuUpdate = "menu_update"
    case limitedCocktail = "limited_cocktail"
    case seasonalSpecial = "seasonal_special"
    case eventNight = "event_night"

    var icon: String {
        switch self {
        case .menuUpdate: return "list.bullet.rectangle"
        case .limitedCocktail: return "hourglass"
        case .seasonalSpecial: return "leaf.fill"
        case .eventNight: return "music.note"
        }
    }

    var label: String {
        switch self {
        case .menuUpdate: return "Menu Update"
        case .limitedCocktail: return "Limited"
        case .seasonalSpecial: return "Seasonal"
        case .eventNight: return "Event"
        }
    }
}

struct BarUpdate: Identifiable, Hashable {
    let id: UUID
    let barID: UUID
    let type: BarUpdateType
    let title: String
    let description: String
    let cocktailID: UUID?
    let eventDate: Date?
    let startsAt: Date?
    let endsAt: Date?
    let createdAt: Date
}

struct NotificationPreferences: Equatable, Codable {
    var savedBarCocktails: Bool
    var happyHourReminders: Bool
    var seasonalLaunches: Bool

    static let `default` = NotificationPreferences(
        savedBarCocktails: true,
        happyHourReminders: true,
        seasonalLaunches: true
    )
}

enum FreshnessBadge: Hashable, Identifiable {
    case newThisWeek
    case seasonal
    case limitedTime
    case trending
    case staffPick
    case featured
    case tonightOnly
    case happyHourNow
    case endingSoon
    case startingSoon
    case newlyOpened
    case updatedTonight
    case updatedThisWeek
    case staleMenu
    case communityVerified

    var id: String {
        switch self {
        case .newThisWeek: return "newThisWeek"
        case .seasonal: return "seasonal"
        case .limitedTime: return "limitedTime"
        case .trending: return "trending"
        case .staffPick: return "staffPick"
        case .featured: return "featured"
        case .tonightOnly: return "tonightOnly"
        case .happyHourNow: return "happyHourNow"
        case .endingSoon: return "endingSoon"
        case .startingSoon: return "startingSoon"
        case .newlyOpened: return "newlyOpened"
        case .updatedTonight: return "updatedTonight"
        case .updatedThisWeek: return "updatedThisWeek"
        case .staleMenu: return "staleMenu"
        case .communityVerified: return "communityVerified"
        }
    }

    var title: String {
        switch self {
        case .newThisWeek: return "New This Week"
        case .seasonal: return "Seasonal"
        case .limitedTime: return "Limited"
        case .trending: return "Trending"
        case .staffPick: return "Staff Pick"
        case .featured: return "Featured"
        case .tonightOnly: return "Tonight Only"
        case .happyHourNow: return "Happy Hour"
        case .endingSoon: return "Ending Soon"
        case .startingSoon: return "Starting Soon"
        case .newlyOpened: return "Just Opened"
        case .updatedTonight: return "Updated Tonight"
        case .updatedThisWeek: return "Updated This Week"
        case .staleMenu: return "May Be Outdated"
        case .communityVerified: return "Verified"
        }
    }

    var icon: String {
        switch self {
        case .newThisWeek: return "sparkle"
        case .seasonal: return "leaf.fill"
        case .limitedTime: return "hourglass"
        case .trending: return "flame.fill"
        case .staffPick: return "star.fill"
        case .featured: return "sparkles"
        case .tonightOnly: return "moon.stars.fill"
        case .happyHourNow: return "clock.fill"
        case .endingSoon: return "clock.badge.exclamationmark.fill"
        case .startingSoon: return "bell.fill"
        case .newlyOpened: return "building.2.fill"
        case .updatedTonight: return "moon.stars.fill"
        case .updatedThisWeek: return "calendar.badge.clock"
        case .staleMenu: return "exclamationmark.triangle.fill"
        case .communityVerified: return "checkmark.seal.fill"
        }
    }

    var tint: String { id }
}

struct HappyHourStatus: Equatable {
    let isActiveNow: Bool
    let isStartingSoon: Bool
    let isEndingSoon: Bool
}

struct ActivityFeedEntry: Identifiable, Hashable {
    var id: UUID { item.id }
    let item: ActivityItem
    let cocktail: Cocktail?
    let bar: Bar?
}
