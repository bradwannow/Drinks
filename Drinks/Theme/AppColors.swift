import SwiftUI

enum AppColors {
    // MARK: - Backgrounds
    static let background = Color(red: 0.04, green: 0.04, blue: 0.05)
    static let backgroundElevated = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let surface = Color(red: 0.11, green: 0.11, blue: 0.13)
    static let surfaceHighlight = Color(red: 0.15, green: 0.15, blue: 0.18)

    // MARK: - Accents
    static let accent = Color(red: 0.79, green: 0.66, blue: 0.38)
    static let accentMuted = Color(red: 0.79, green: 0.66, blue: 0.38, opacity: 0.6)
    static let accentSecondary = Color(red: 0.55, green: 0.22, blue: 0.28)

    // MARK: - Text
    static let textPrimary = Color(red: 0.95, green: 0.94, blue: 0.92)
    static let textSecondary = Color(red: 0.65, green: 0.63, blue: 0.60)
    static let textTertiary = Color(red: 0.45, green: 0.43, blue: 0.40)

    // MARK: - Gradients
    static let heroGradient = LinearGradient(
        colors: [
            Color.clear,
            Color.black.opacity(0.3),
            Color.black.opacity(0.85)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardOverlay = LinearGradient(
        colors: [
            Color.black.opacity(0.0),
            Color.black.opacity(0.65)
        ],
        startPoint: .center,
        endPoint: .bottom
    )

    static let screenGradient = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.05, blue: 0.08),
            background
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGlow = RadialGradient(
        colors: [
            accent.opacity(0.15),
            Color.clear
        ],
        center: .topLeading,
        startRadius: 0,
        endRadius: 300
    )
}
