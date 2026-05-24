import Foundation

struct SearchFilters: Equatable {
    var spirit: String?
    var neighborhood: String?
    var happyHourNow = false
    var featuredOnly = false
    var seasonalOnly = false
    var savedOnly = false

    var isActive: Bool {
        spirit != nil
            || neighborhood != nil
            || happyHourNow
            || featuredOnly
            || seasonalOnly
            || savedOnly
    }

    var activeCount: Int {
        [
            spirit != nil,
            neighborhood != nil,
            happyHourNow,
            featuredOnly,
            seasonalOnly,
            savedOnly
        ].filter { $0 }.count
    }

    mutating func clear() {
        spirit = nil
        neighborhood = nil
        happyHourNow = false
        featuredOnly = false
        seasonalOnly = false
        savedOnly = false
    }

    mutating func applySpirit(_ spirit: String) {
        self.spirit = spirit
    }

    mutating func applyNeighborhood(_ neighborhood: String) {
        self.neighborhood = neighborhood
    }

    mutating func toggle(_ toggle: SearchFilterToggle) {
        switch toggle {
        case .happyHourNow: happyHourNow.toggle()
        case .featuredOnly: featuredOnly.toggle()
        case .seasonalOnly: seasonalOnly.toggle()
        case .savedOnly: savedOnly.toggle()
        }
    }
}

enum SearchFilterToggle: String, CaseIterable, Identifiable {
    case happyHourNow
    case featuredOnly
    case seasonalOnly
    case savedOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .happyHourNow: return "Happy Hour"
        case .featuredOnly: return "Featured"
        case .seasonalOnly: return "Seasonal"
        case .savedOnly: return "Saved"
        }
    }

    var icon: String {
        switch self {
        case .happyHourNow: return "clock.fill"
        case .featuredOnly: return "sparkles"
        case .seasonalOnly: return "leaf.fill"
        case .savedOnly: return "bookmark.fill"
        }
    }
}

struct SearchResults: Equatable {
    var bars: [Bar] = []
    var cocktails: [Cocktail] = []
    var neighborhoods: [String] = []
    var spirits: [String] = []

    var isEmpty: Bool {
        bars.isEmpty && cocktails.isEmpty && neighborhoods.isEmpty && spirits.isEmpty
    }

    var totalCount: Int {
        bars.count + cocktails.count
    }
}
