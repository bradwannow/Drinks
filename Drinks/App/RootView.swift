import SwiftUI

struct RootView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var saveStore: SaveStore

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
                    }

            case .authenticated:
                MainTabView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    .task {
                        await saveStore.load()
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
        .preferredColorScheme(.dark)
}
