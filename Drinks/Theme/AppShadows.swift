import SwiftUI

enum AppShadows {
    static func card() -> some ViewModifier {
        CardShadowModifier(
            color: Color.black.opacity(0.4),
            radius: 12,
            y: 6
        )
    }

    static func elevated() -> some ViewModifier {
        CardShadowModifier(
            color: Color.black.opacity(0.55),
            radius: 20,
            y: 10
        )
    }

    static func glow() -> some ViewModifier {
        CardShadowModifier(
            color: AppColors.accent.opacity(0.12),
            radius: 16,
            y: 4
        )
    }
}

private struct CardShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: 0, y: y)
    }
}

extension View {
    func cardShadow() -> some View {
        modifier(AppShadows.card())
    }

    func elevatedShadow() -> some View {
        modifier(AppShadows.elevated())
    }

    func glowShadow() -> some View {
        modifier(AppShadows.glow())
    }
}
