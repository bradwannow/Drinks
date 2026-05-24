import Foundation

final class RecentSearchStore {
    static let shared = RecentSearchStore()

    private let storageKey = "pour.recentSearches"
    private let maxCount = 8
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [String] {
        defaults.stringArray(forKey: storageKey) ?? []
    }

    func add(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        var entries = load().filter { $0.localizedCaseInsensitiveCompare(trimmed) != .orderedSame }
        entries.insert(trimmed, at: 0)
        defaults.set(Array(entries.prefix(maxCount)), forKey: storageKey)
    }

    func remove(_ term: String) {
        var entries = load()
        entries.removeAll { $0.localizedCaseInsensitiveCompare(term) == .orderedSame }
        defaults.set(entries, forKey: storageKey)
    }

    func clear() {
        defaults.removeObject(forKey: storageKey)
    }
}
