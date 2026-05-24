import SwiftUI

struct CocktailDetailView: View {
    @StateObject private var viewModel: CocktailDetailViewModel
    @EnvironmentObject private var saveStore: SaveStore

    init(cocktail: Cocktail) {
        _viewModel = StateObject(wrappedValue: CocktailDetailViewModel(cocktail: cocktail))
    }

    init(cocktailID: UUID) {
        _viewModel = StateObject(wrappedValue: CocktailDetailViewModel(cocktailID: cocktailID))
    }

    var body: some View {
        Group {
            if let content = viewModel.loadState.value {
                detailContent(content)
            } else if viewModel.loadState.isLoading, let cocktail = viewModel.displayCocktail {
                detailContent(
                    CocktailDetailContent(cocktail: cocktail, relatedCocktails: []),
                    isPlaceholder: true
                )
            } else if let error = viewModel.loadState.error {
                errorState(error)
            } else {
                ProgressView()
                    .tint(AppColors.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            if let cocktail = viewModel.displayCocktail {
                ToolbarItem(placement: .topBarTrailing) {
                    SaveButton(isSaved: saveStore.isCocktailSaved(cocktail.id)) {
                        Task { await saveStore.toggleCocktail(cocktail.id) }
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func detailContent(_ content: CocktailDetailContent, isPlaceholder: Bool = false) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroSection(cocktail: content.cocktail)
                    .fadeInOnAppear()

                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    headerSection(cocktail: content.cocktail)
                        .fadeInOnAppear(delay: 0.05)

                    badgesSection(cocktail: content.cocktail)
                        .fadeInOnAppear(delay: 0.08)

                    tastingNotesSection(cocktail: content.cocktail)
                        .fadeInOnAppear(delay: 0.1)

                    if !content.relatedCocktails.isEmpty || isPlaceholder {
                        relatedSection(content.relatedCocktails, isPlaceholder: isPlaceholder)
                            .fadeInOnAppear(delay: 0.15)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
    }

    private func heroSection(cocktail: Cocktail) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImageView(
                url: cocktail.imageURL,
                cornerRadius: 0,
                showGradientOverlay: false
            )
            .frame(height: 400)
            .clipped()

            AppColors.heroGradient
                .frame(height: 400)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                BadgePill(title: cocktail.spirit, icon: "drop.fill")
            }
            .padding(AppSpacing.lg)
        }
    }

    private func headerSection(cocktail: Cocktail) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(cocktail.name)
                .displayMediumStyle()

            Label(cocktail.barName, systemImage: "mappin.circle.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.accentMuted)
        }
    }

    @ViewBuilder
    private func badgesSection(cocktail: Cocktail) -> some View {
        if cocktail.isFeatured || cocktail.isTrending || cocktail.isSeasonal {
            HStack(spacing: AppSpacing.xs) {
                if cocktail.isFeatured {
                    BadgePill(title: "Featured", icon: "sparkles")
                }
                if cocktail.isTrending {
                    BadgePill(title: "Trending", icon: "flame.fill", tint: AppColors.accentSecondary)
                }
                if cocktail.isSeasonal {
                    BadgePill(title: "Seasonal", icon: "leaf.fill", tint: AppColors.accentSecondary)
                }
            }
        }
    }

    private func tastingNotesSection(cocktail: Cocktail) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "Ingredients & Notes", subtitle: "What's in the glass")

            Text(cocktail.description)
                .bodyStyle()
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
    }

    private func relatedSection(_ cocktails: [Cocktail], isPlaceholder: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Related Pours", subtitle: "More like this")

            if isPlaceholder && cocktails.isEmpty {
                ProgressView()
                    .tint(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(cocktails) { cocktail in
                            NavigationLink(value: cocktail) {
                                RelatedCocktailCard(cocktail: cocktail)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func errorState(_ error: NetworkError) -> some View {
        ContentStateView(
            icon: "wifi.exclamationmark",
            title: "Couldn't load cocktail",
            message: error.errorDescription ?? "Something went wrong.",
            actionTitle: "Try again",
            action: {
                Task { await viewModel.load() }
            },
            style: .card
        )
        .padding(AppSpacing.screenPadding)
    }
}

#Preview {
    NavigationStack {
        CocktailDetailView(cocktail: MockDataService.featuredCocktail)
            .detailNavigation()
    }
    .environmentObject(SaveStore.shared)
    .preferredColorScheme(.dark)
}
