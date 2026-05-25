import SwiftUI

@main
struct DrinksApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var saveStore = SaveStore.shared
    @StateObject private var notificationPreferencesStore = NotificationPreferencesStore.shared

    init() {
        _ = SupabaseManager.shared

        #if DEBUG
        if !AppConfig.isSupabaseConfigured {
            print("[Drinks] Supabase credentials not configured. Update Drinks/Config/SupabaseSecrets.plist.")
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(saveStore)
                .environmentObject(notificationPreferencesStore)
                .preferredColorScheme(.dark)
        }
    }
}
