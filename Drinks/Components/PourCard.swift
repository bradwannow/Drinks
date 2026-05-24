import SwiftUI

struct PourCard<Content: View>: View {
    var padding: CGFloat = AppSpacing.md
    var cornerRadius: CGFloat = AppSpacing.cardRadius
    var elevated: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColors.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(AppColors.surfaceHighlight.opacity(0.5), lineWidth: 0.5)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .modifier(CardShadowStyle(elevated: elevated))
    }
}

private struct CardShadowStyle: ViewModifier {
    let elevated: Bool

    func body(content: Content) -> some View {
        if elevated {
            content.modifier(AppShadows.elevated())
        } else {
            content.modifier(AppShadows.card())
        }
    }
}

#Preview {
    PourCard {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Velvet Room")
                .headlineStyle()
            Text("Speakeasy classics, candlelit booths")
                .bodyStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
