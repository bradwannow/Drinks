import SwiftUI

struct ContentStateView: View {
    enum Style {
        case inline
        case card
    }

    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?
    var style: Style = .inline

    var body: some View {
        Group {
            switch style {
            case .inline:
                inlineContent
            case .card:
                cardContent
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var inlineContent: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(AppColors.accentMuted)

            Text(title)
                .headlineStyle()

            Text(message)
                .bodyStyle()
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
                    .padding(.top, AppSpacing.xs)
            }
        }
        .padding(.vertical, AppSpacing.lg)
    }

    private var cardContent: some View {
        inlineContent
            .padding(AppSpacing.lg)
            .background {
                RoundedRectangle(cornerRadius: AppSpacing.cardRadiusLarge, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppSpacing.cardRadiusLarge, style: .continuous)
                            .strokeBorder(AppColors.surfaceHighlight.opacity(0.5), lineWidth: 0.5)
                    }
            }
            .cardShadow()
    }
}

struct HomeLoadingOverlay: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .tint(AppColors.accent)
                .scaleEffect(1.1)

            Text("Curating tonight's picks…")
                .captionStyle()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
    }
}

#Preview {
    VStack(spacing: AppSpacing.xl) {
        ContentStateView(
            icon: "wineglass",
            title: "No cocktails yet",
            message: "Check back soon for featured pours.",
            style: .card
        )

        ContentStateView(
            icon: "wifi.exclamationmark",
            title: "Couldn't load",
            message: "Something went wrong reaching the bar.",
            actionTitle: "Try again",
            action: {}
        )
    }
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
