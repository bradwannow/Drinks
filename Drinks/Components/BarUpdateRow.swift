import SwiftUI

struct BarUpdateRow: View {
    let update: BarUpdate

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: update.type.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    BadgePill(title: update.type.label, icon: update.type.icon)
                    Spacer(minLength: 0)
                    Text(update.createdAt.formatted(.relative(presentation: .named)))
                        .captionStyle()
                }

                Text(update.title)
                    .headlineStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(update.description)
                    .bodyStyle()
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                if let eventDate = update.eventDate {
                    Label(eventDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.accentMuted)
                }
            }
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .fill(AppColors.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                        .strokeBorder(AppColors.surfaceHighlight.opacity(0.5), lineWidth: 0.5)
                }
        }
        .cardShadow()
    }
}

#Preview {
    BarUpdateRow(
        update: BarUpdate(
            id: UUID(),
            barID: UUID(),
            type: .seasonalSpecial,
            title: "Spring Aperitif Menu",
            description: "Light, floral highballs rotating through April.",
            cocktailID: nil,
            eventDate: Date(),
            startsAt: Date(),
            endsAt: nil,
            createdAt: Date()
        )
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
