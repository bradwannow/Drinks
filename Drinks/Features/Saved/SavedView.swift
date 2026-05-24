import SwiftUI

struct SavedView: View {
    @StateObject private var viewModel = SavedViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading && viewModel.savedBars.isEmpty && viewModel.savedCocktails.isEmpty {
                    loadingState
                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.savedBars.isEmpty && viewModel.savedCocktails.isEmpty {
                    errorState(message: errorMessage)
                } else if viewModel.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .screenBackground()
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .detailNavigation()
            .task {
                await viewModel.load()
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            if let errorMessage = viewModel.errorMessage {
                ContentStateView(
                    icon: "exclamationmark.triangle",
                    title: "Couldn't refresh saves",
                    message: errorMessage,
                    actionTitle: "Try again",
                    action: {
                        Task { await viewModel.refresh() }
                    },
                    style: .card
                )
            }

            if !viewModel.savedBars.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(title: "Bars", subtitle: "\(viewModel.savedBars.count) saved")
                        .fadeInOnAppear()

                    VStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.savedBars) { bar in
                            NavigationLink(value: bar) {
                                BarCard(bar: bar, style: .wide)
                            }
                            .buttonStyle(.plain)
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
                            NavigationLink(value: cocktail) {
                                SavedCocktailRow(cocktail: cocktail)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .fadeInOnAppear(delay: 0.15)
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.bottom, AppSpacing.xxl)
    }

    private var loadingState: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .tint(AppColors.accent)
            Text("Loading your saves…")
                .captionStyle()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xxl)
    }

    private func errorState(message: String) -> some View {
        ContentStateView(
            icon: "wifi.exclamationmark",
            title: "Couldn't load saves",
            message: message,
            actionTitle: "Try again",
            action: {
                Task { await viewModel.refresh() }
            },
            style: .card
        )
        .padding(AppSpacing.screenPadding)
        .padding(.top, AppSpacing.xl)
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

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
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
        .environmentObject(SaveStore.shared)
        .preferredColorScheme(.dark)
}
