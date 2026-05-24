import SwiftUI

enum AppTab: Hashable {
    case home
    case search
    case saved
    case profile
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(AppTab.search)

            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }
                .tag(AppTab.saved)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(AppTab.profile)
        }
        .tint(AppColors.accent)
        .toolbarBackground(AppColors.backgroundElevated, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(SaveStore.shared)
        .preferredColorScheme(.dark)
}
