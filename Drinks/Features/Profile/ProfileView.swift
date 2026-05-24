import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    profileHeader
                        .fadeInOnAppear()

                    statsRow
                        .fadeInOnAppear(delay: 0.05)

                    ForEach(Array(viewModel.menuSections.enumerated()), id: \.offset) { index, section in
                        menuSection(section)
                            .fadeInOnAppear(delay: 0.1 + Double(index) * 0.05)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
            .screenBackground()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var profileHeader: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.accent.opacity(0.3), AppColors.accentSecondary.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                Text("BW")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .glowShadow()

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("Brad Wannow")
                    .titleStyle()

                Text("Cocktail explorer · West Village")
                    .bodyStyle()
            }

            Spacer()
        }
        .padding(.top, AppSpacing.sm)
    }

    private var statsRow: some View {
        HStack(spacing: AppSpacing.sm) {
            StatCard(value: "12", label: "Visited")
            StatCard(value: "8", label: "Saved")
            StatCard(value: "24", label: "Pours")
        }
    }

    private func menuSection(_ items: [ProfileMenuItem]) -> some View {
        PourCard(padding: 0) {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    ProfileMenuRow(item: item)

                    if index < items.count - 1 {
                        Divider()
                            .background(AppColors.surfaceHighlight)
                            .padding(.leading, 52)
                    }
                }
            }
        }
    }
}

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(AppColors.textPrimary)

            Text(label)
                .captionStyle()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
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

private struct ProfileMenuRow: View {
    let item: ProfileMenuItem

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: item.icon)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .headlineStyle()

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .captionStyle()
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm + 2)
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
