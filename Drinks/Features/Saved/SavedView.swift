import SwiftUI

struct SavedView: View {
    @StateObject private var viewModel = SavedViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .screenBackground()
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            if !viewModel.savedBars.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(title: "Bars", subtitle: "\(viewModel.savedBars.count) saved")
                        .fadeInOnAppear()

                    VStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.savedBars) { bar in
                            BarCard(bar: bar, style: .wide)
                        }
                    }
                    .fadeInOnAppear(delay: 0.05)
                }
            }

            if !viewModel.savedCocktails.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(title: "Cocktails", subtitle: "\(viewModel.savedCocktails.count) saved")
                        .fadeInOnAppear(delay: 0.1)

                    VStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.savedCocktails) { cocktail in
                            SavedCocktailRow(cocktail: cocktail)
                        }
                    }
                    .fadeInOnAppear(delay: 0.15)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.bottom, AppSpacing.xxl)
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.accent.opacity(0.6))

            VStack(spacing: AppSpacing.xs) {
                Text("Nothing saved yet")
                    .titleStyle()

                Text("Bookmark bars and cocktails to build your personal shortlist.")
                    .bodyStyle()
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xxl)
        .fadeInOnAppear()
    }
}

private struct SavedCocktailRow: View {
    let cocktail: Cocktail

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImageView(
                url: cocktail.imageURL,
                cornerRadius: AppSpacing.sm
            )
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(cocktail.name)
                    .headlineStyle()

                Text(cocktail.barName)
                    .captionStyle()

                Text(cocktail.spirit)
                    .labelStyle()
            }

            Spacer()
        }
        .padding(AppSpacing.sm)
        .background {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .fill(AppColors.surface)
        }
        .cardShadow()
    }
}

#Preview {
    SavedView()
        .preferredColorScheme(.dark)
}
