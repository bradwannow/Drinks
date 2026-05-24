import Foundation

struct ProfileMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let subtitle: String?
    var isDestructive: Bool = false
}

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var menuSections: [[ProfileMenuItem]]

    init() {
        menuSections = [
            [
                ProfileMenuItem(title: "Preferences", icon: "slider.horizontal.3", subtitle: "Spirits, vibes, dietary"),
                ProfileMenuItem(title: "Notifications", icon: "bell", subtitle: "Happy hour alerts, new menus")
            ],
            [
                ProfileMenuItem(title: "Nightlife Pass", icon: "sparkles", subtitle: "Exclusive access & perks"),
                ProfileMenuItem(title: "Invite Friends", icon: "person.2", subtitle: nil)
            ],
            [
                ProfileMenuItem(title: "Help & Support", icon: "questionmark.circle", subtitle: nil),
                ProfileMenuItem(title: "About Pour", icon: "info.circle", subtitle: "Version 1.0")
            ],
            [
                ProfileMenuItem(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", subtitle: nil, isDestructive: true)
            ]
        ]
    }
}
