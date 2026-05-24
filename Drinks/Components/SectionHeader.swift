import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .captionStyle()
                }
            }

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.accent)
                }
            }
        }
    }
}

#Preview {
    SectionHeader(
        title: "Trending Bars",
        subtitle: "What everyone's talking about",
        actionTitle: "See all"
    ) {}
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
