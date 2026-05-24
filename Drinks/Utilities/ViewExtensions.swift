import SwiftUI

extension View {
    func screenBackground() -> some View {
        background {
            ZStack {
                AppColors.background.ignoresSafeArea()
                AppColors.screenGradient.ignoresSafeArea()
                AppColors.accentGlow.ignoresSafeArea()
            }
        }
    }

    func fadeInOnAppear(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
}

private struct FadeInModifier: ViewModifier {
    @State private var isVisible = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    isVisible = true
                }
            }
    }
}
