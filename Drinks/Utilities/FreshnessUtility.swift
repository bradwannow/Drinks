import Foundation

enum FreshnessUtility {
    private static let newThisWeekInterval: TimeInterval = 7 * 24 * 60 * 60
    private static let tonightOnlyLeadInterval: TimeInterval = 24 * 60 * 60

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
