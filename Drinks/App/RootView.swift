import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var saveStore: SaveStore
    @EnvironmentObject private var notificationPreferencesStore: NotificationPreferencesStore

    var body: some View {
        Group {
            switch authViewModel.phase {
            case .initializing:
                AuthLoadingView()
                    .transition(.opacity)

            case .unauthenticated:
                AuthFlowView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .onAppear {
                        saveStore.reset()
                        notificationPreferencesStore.reset()
                    }

            case .authenticated:
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    .task {
                        async let saves: Void = saveStore.load()
                        async let prefs: Void = notificationPreferencesStore.load()
                        _ = await (saves, prefs)
                    }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authViewModel.phase)
    }
}

private struct AuthLoadingView: View {
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Pour")
                .displayMediumStyle()

            ProgressView()
                .tint(AppColors.accent)
                .scaleEffect(1.1)

            Text("Opening the bar…")
                .captionStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
        .environmentObject(SaveStore.shared)
        .environmentObject(NotificationPreferencesStore.shared)
        .preferredColorScheme(.dark)
}
