import Foundation

enum FreshnessUtility {
    private static let tonightInterval: TimeInterval = 24 * 60 * 60
    private static let weekInterval: TimeInterval = 7 * 24 * 60 * 60
    private static let staleInterval: TimeInterval = 30 * 24 * 60 * 60

    static func menuFreshnessLevel(uploadedAt: Date, at date: Date = Date()) -> MenuFreshnessLevel {
        let age = date.timeIntervalSince(uploadedAt)
        if age <= tonightInterval { return .updatedTonight }
        if age <= weekInterval { return .updatedThisWeek }
        if age <= staleInterval { return .current }
        return .stale
    }

    static func badges(for menu: MenuVersion, at date: Date = Date()) -> [FreshnessBadge] {
        var badges: [FreshnessBadge] = []

        if menu.isOutdated {
            badges.append(.staleMenu)
        } else {
            switch menu.freshnessLevel(at: date) {
            case .updatedTonight: badges.append(.updatedTonight)
            case .updatedThisWeek: badges.append(.updatedThisWeek)
            case .stale: badges.append(.staleMenu)
            default: break
            }
        }

        if menu.isCommunityVerified { badges.append(.communityVerified) }
        if menu.isSeasonal { badges.append(.seasonal) }

        return deduplicatedPriority(badges)
    }

    static func menuLastUpdatedLabel(for uploadedAt: Date, at date: Date = Date()) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        let relative = formatter.localizedString(for: uploadedAt, relativeTo: date)

        switch menuFreshnessLevel(uploadedAt: uploadedAt, at: date) {
        case .updatedTonight:
            return "Updated tonight · \(relative)"
        case .updatedThisWeek:
            return "Updated this week · \(relative)"
        case .stale, .outdated:
            return "Last updated · \(relative)"
        case .current:
            return "Last updated · \(relative)"
        }
    }

    static func badges(for cocktail: Cocktail, at date: Date = Date()) -> [FreshnessBadge] {
        var badges: [FreshnessBadge] = []

        if cocktail.isNewThisWeek(at: date) { badges.append(.newThisWeek) }
        if cocktail.isTonightOnly(at: date) { badges.append(.tonightOnly) }
        if cocktail.isLimitedTime { badges.append(.limitedTime) }
        if cocktail.isStaffPick { badges.append(.staffPick) }
        if cocktail.isSeasonal { badges.append(.seasonal) }
        if cocktail.isTrending { badges.append(.trending) }
        if cocktail.isFeatured { badges.append(.featured) }

        return deduplicatedPriority(badges)
    }

    static func badges(for bar: Bar, at date: Date = Date()) -> [FreshnessBadge] {
        var badges: [FreshnessBadge] = []
        if bar.isNewlyOpened { badges.append(.newlyOpened) }
        if bar.isTrending { badges.append(.trending) }
        if bar.isFeatured { badges.append(.featured) }
        if bar.isNewThisWeek(at: date) { badges.append(.newThisWeek) }
        return deduplicatedPriority(badges)
    }

    static func happyHourStatus(for happyHour: HappyHour, at date: Date = Date()) -> HappyHourStatus {
        let active = HappyHourUtility.isActiveNow(happyHour, at: date)
        let startingSoon = !active && HappyHourUtility.isStartingSoon(happyHour, at: date)
        let endingSoon = active && HappyHourUtility.isEndingSoon(happyHour, at: date)
        return HappyHourStatus(isActiveNow: active, isStartingSoon: startingSoon, isEndingSoon: endingSoon)
    }

    static func happyHourBadges(for happyHour: HappyHour, at date: Date = Date()) -> [FreshnessBadge] {
        let status = happyHourStatus(for: happyHour, at: date)
        var badges: [FreshnessBadge] = []
        if status.isActiveNow { badges.append(.happyHourNow) }
        if status.isEndingSoon { badges.append(.endingSoon) }
        if status.isStartingSoon { badges.append(.startingSoon) }
        return badges
    }

    private static func deduplicatedPriority(_ badges: [FreshnessBadge]) -> [FreshnessBadge] {
        var seen = Set<String>()
        return badges.filter { seen.insert($0.id).inserted }
    }
}

extension Cocktail {
    func isNewThisWeek(at date: Date = Date()) -> Bool {
        guard let createdAt else { return false }
        return date.timeIntervalSince(createdAt) <= 7 * 24 * 60 * 60
    }

    func isTonightOnly(at date: Date = Date()) -> Bool {
        guard let availableUntil else { return false }
        let calendar = Calendar.current
        return calendar.isDate(availableUntil, inSameDayAs: date)
            && availableUntil.timeIntervalSince(date) <= 24 * 60 * 60
            && availableUntil > date
    }
}

extension Bar {
    func isNewThisWeek(at date: Date = Date()) -> Bool {
        guard let createdAt else { return false }
        return date.timeIntervalSince(createdAt) <= 7 * 24 * 60 * 60
    }
}
