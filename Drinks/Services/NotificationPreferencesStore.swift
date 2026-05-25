import Foundation

@MainActor
final class NotificationPreferencesStore: ObservableObject {
    static let shared = NotificationPreferencesStore()

    @Published private(set) var preferences: NotificationPreferences = .default
    @Published private(set) var isSynced = false

    private let database: DatabaseService
    private let defaults: UserDefaults
    private let storageKey = "pour.notificationPreferences"

    init(database: DatabaseService = .shared, defaults: UserDefaults = .standard) {
        self.database = database
        self.defaults = defaults
        loadCached()
    }

    func load() async {
        do {
            preferences = try await database.fetchNotificationPreferences()
            cache(preferences)
            isSynced = true
        } catch {
            loadCached()
            isSynced = false
        }
    }

    func update(_ preferences: NotificationPreferences) async {
        self.preferences = preferences
        cache(preferences)

        do {
            self.preferences = try await database.upsertNotificationPreferences(preferences)
            cache(self.preferences)
            isSynced = true
        } catch {
            isSynced = false
        }
    }

    func reset() {
        preferences = .default
        defaults.removeObject(forKey: storageKey)
        isSynced = false
    }

    /// Hook for future push notification registration.
    var pendingNotificationTopics: [String] {
        var topics: [String] = []
        if preferences.savedBarCocktails { topics.append("saved_bar_cocktails") }
        if preferences.happyHourReminders { topics.append("happy_hour_reminders") }
        if preferences.seasonalLaunches { topics.append("seasonal_launches") }
        return topics
    }

    private func loadCached() {
        guard
            let data = defaults.data(forKey: storageKey),
            let cached = try? JSONDecoder().decode(NotificationPreferences.self, from: data)
        else {
            preferences = .default
            return
        }
        preferences = cached
    }

    private func cache(_ preferences: NotificationPreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
