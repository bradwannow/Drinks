import SwiftUI

struct MenuValidationBar: View {
    let version: MenuVersion
    let viewerState: MenuViewerState
    var isProcessing: Bool = false
    var onConfirm: () -> Void
    var onReportOutdated: () -> Void

    var body: some View {
        PourCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Community Trust")
                            .labelStyle()
                        Text(version.confidenceLabel)
                            .headlineStyle()
                        Text(trustDetail)
                            .captionStyle()
                    }

                    Spacer()

                    confidenceRing
                }

                if version.isCurrent {
                    HStack(spacing: AppSpacing.sm) {
                        Button(action: onConfirm) {
                            Label(confirmTitle, systemImage: "checkmark.seal")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(viewerState.hasConfirmed ? AppColors.surfaceHighlight : AppColors.accent.opacity(0.15))
                                .foregroundStyle(viewerState.hasConfirmed ? AppColors.textSecondary : AppColors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
                        }
                        .disabled(viewerState.hasConfirmed || isProcessing)

                        Button(action: onReportOutdated) {
                            Label(outdatedTitle, systemImage: "clock.badge.exclamationmark")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.sm)
                                .background(viewerState.hasReportedOutdated ? AppColors.surfaceHighlight : AppColors.accentSecondary.opacity(0.15))
                                .foregroundStyle(viewerState.hasReportedOutdated ? AppColors.textSecondary : AppColors.accentSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
                        }
                        .disabled(viewerState.hasReportedOutdated || isProcessing)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var trustDetail: String {
        if version.confirmationCount == 0 {
            return "Be the first to confirm this menu is current"
        }
        return "\(version.confirmationCount) confirmation\(version.confirmationCount == 1 ? "" : "s") from the community"
    }

    private var confirmTitle: String {
        viewerState.hasConfirmed ? "Confirmed" : "Confirm Current"
    }

    private var outdatedTitle: String {
        viewerState.hasReportedOutdated ? "Reported" : "Mark Outdated"
    }

    private var confidenceRing: some View {
        ZStack {
            Circle()
                .stroke(AppColors.surfaceHighlight, lineWidth: 4)
            Circle()
                .trim(from: 0, to: CGFloat(version.confidenceScore))
                .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(version.confidenceScore * 100))")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppColors.accent)
        }
        .frame(width: 44, height: 44)
    }
}

#Preview {
    MenuValidationBar(
        version: MenuVersion(
            id: UUID(),
            menuID: UUID(),
            barID: UUID(),
            contributorID: nil,
            contributorName: "Jordan",
            seasonLabel: "Winter",
            seasonMonth: 12,
            isCurrent: true,
            notes: nil,
            ocrStatus: .completed,
            uploadedAt: Date(),
            createdAt: Date(),
            versionNumber: 2,
            imageCount: 2,
            cocktailCount: 8,
            coverImageURL: nil,
            confirmationCount: 4,
            confidenceScore: 0.73,
            isOutdated: false
        ),
        viewerState: .anonymous,
        onConfirm: {},
        onReportOutdated: {}
    )
    .padding()
    .screenBackground()
    .preferredColorScheme(.dark)
}
