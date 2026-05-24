import Foundation

enum HappyHourUtility {
    static func isActiveNow(_ happyHour: HappyHour, at date: Date = Date(), calendar: Calendar = .current) -> Bool {
        isDayActive(happyHour.daysActive, on: date, calendar: calendar)
            && isTimeActive(happyHour.timeRange, at: date, calendar: calendar)
    }

    static func isDayActive(_ daysActive: String, on date: Date, calendar: Calendar) -> Bool {
        let normalized = daysActive.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.contains("daily") { return true }

        let weekday = calendar.component(.weekday, from: date)
        let dayIndex = weekday == 1 ? 7 : weekday - 1

        if let range = dayRange(in: normalized) {
            return dayIndex >= range.lowerBound && dayIndex <= range.upperBound
        }

        return normalized.contains(dayName(for: dayIndex))
    }

    static func isTimeActive(_ timeRange: String, at date: Date, calendar: Calendar) -> Bool {
        guard let bounds = timeBounds(from: timeRange) else { return false }

        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return false }

        let currentMinutes = hour * 60 + minute
        return currentMinutes >= bounds.start && currentMinutes <= bounds.end
    }

    private static func dayName(for index: Int) -> String {
        switch index {
        case 1: return "mon"
        case 2: return "tue"
        case 3: return "wed"
        case 4: return "thu"
        case 5: return "fri"
        case 6: return "sat"
        case 7: return "sun"
        default: return ""
        }
    }

    private static func dayRange(in text: String) -> ClosedRange<Int>? {
        let tokens = text
            .replacingOccurrences(of: "–", with: "-")
            .split(separator: "-")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard tokens.count == 2,
              let start = dayIndex(for: String(tokens[0])),
              let end = dayIndex(for: String(tokens[1])) else {
            return nil
        }

        return start...end
    }

    private static func dayIndex(for token: String) -> Int? {
        let value = token.lowercased()
        if value.hasPrefix("mon") { return 1 }
        if value.hasPrefix("tue") { return 2 }
        if value.hasPrefix("wed") { return 3 }
        if value.hasPrefix("thu") { return 4 }
        if value.hasPrefix("fri") { return 5 }
        if value.hasPrefix("sat") { return 6 }
        if value.hasPrefix("sun") { return 7 }
        return nil
    }

    private static func timeBounds(from timeRange: String) -> (start: Int, end: Int)? {
        let normalized = timeRange
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: "—", with: "-")
            .lowercased()

        let parts = normalized.split(separator: "-").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard parts.count == 2,
              let start = minutes(from: String(parts[0])),
              let end = minutes(from: String(parts[1])) else {
            return nil
        }

        return (start, end)
    }

    private static func minutes(from token: String) -> Int? {
        let cleaned = token
            .replacingOccurrences(of: "pm", with: " pm")
            .replacingOccurrences(of: "am", with: " am")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let isPM = cleaned.contains("pm")
        let isAM = cleaned.contains("am")
        let numeric = cleaned
            .replacingOccurrences(of: "pm", with: "")
            .replacingOccurrences(of: "am", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let timeParts = numeric.split(separator: ":").map(String.init)
        guard let hourValue = Int(timeParts[0]) else { return nil }

        let minuteValue = timeParts.count > 1 ? (Int(timeParts[1]) ?? 0) : 0
        var hour = hourValue

        if isPM && hour < 12 { hour += 12 }
        if isAM && hour == 12 { hour = 0 }
        if !isPM && !isAM && hour <= 7 { hour += 12 }

        return hour * 60 + minuteValue
    }
}
