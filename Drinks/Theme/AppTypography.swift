import SwiftUI

enum AppTypography {
    static func displayLarge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 34, weight: .bold, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
    }

    static func displayMedium(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 28, weight: .bold, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
    }

    static func title(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .semibold, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
    }

    static func headline(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(AppColors.textPrimary)
    }

    static func body(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(AppColors.textSecondary)
    }

    static func caption(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(AppColors.textTertiary)
    }

    static func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundStyle(AppColors.accent)
    }
}

extension View {
    func displayLargeStyle() -> some View {
        font(.system(size: 34, weight: .bold, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
    }

    func displayMediumStyle() -> some View {
        font(.system(size: 28, weight: .bold, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
    }

    func titleStyle() -> some View {
        font(.system(size: 22, weight: .semibold, design: .serif))
            .foregroundStyle(AppColors.textPrimary)
    }

    func headlineStyle() -> some View {
        font(.system(size: 17, weight: .semibold))
            .foregroundStyle(AppColors.textPrimary)
    }

    func bodyStyle() -> some View {
        font(.system(size: 15, weight: .regular))
            .foregroundStyle(AppColors.textSecondary)
    }

    func captionStyle() -> some View {
        font(.system(size: 13, weight: .medium))
            .foregroundStyle(AppColors.textTertiary)
    }

    func labelStyle() -> some View {
        font(.system(size: 11, weight: .semibold))
            .tracking(1.2)
            .textCase(.uppercase)
            .foregroundStyle(AppColors.accent)
    }
}
