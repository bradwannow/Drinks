import SwiftUI

struct BarDetailView: View {
    @StateObject private var viewModel: BarDetailViewModel
    @EnvironmentObject private var saveStore: SaveStore

    init(bar: Bar) {
        _viewModel = StateObject(wrappedValue: BarDetailViewModel(bar: bar))
    }

    init(barID: UUID) {
        _viewModel = StateObject(wrappedValue: BarDetailViewModel(barID: barID))
    }

    var body: some View {
        Group {
            if let content = viewModel.loadState.value {
                detailContent(content)
            } else if viewModel.loadState.isLoading, let bar = viewModel.displayBar {
                detailContent(
                    BarDetailContent(bar: bar, cocktails: [], happyHours: []),
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
            if let bar = viewModel.displayBar {
                ToolbarItem(placement: .topBarTrailing) {
                    SaveButton(isSaved: saveStore.isBarSaved(bar.id)) {
                        Task { await saveStore.toggleBar(bar.id) }
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func detailContent(_ content: BarDetailContent, isPlaceholder: Bool = false) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroSection(bar: content.bar)
                    .fadeInOnAppear()

                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    headerSection(bar: content.bar)
                        .fadeInOnAppear(delay: 0.05)

                    descriptionSection(bar: content.bar)
                        .fadeInOnAppear(delay: 0.08)

                    if !content.happyHours.isEmpty {
                        happyHourSection(content.happyHours)
                            .fadeInOnAppear(delay: 0.1)
                    }

                    cocktailSection(content.cocktails, isPlaceholder: isPlaceholder)
                        .fadeInOnAppear(delay: 0.15)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
    }

    private func heroSection(bar: Bar) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImageView(
                url: bar.imageURL,
                cornerRadius: 0,
                showGradientOverlay: false
            )
            .frame(maxWidth: .infinity)
            .frame(height: 360)

            AppColors.heroGradient
                .frame(maxWidth: .infinity)
                .frame(height: 360)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                if bar.isFeatured || bar.isTrending {
                    HStack(spacing: AppSpacing.xs) {
                        if bar.isFeatured {
                            BadgePill(title: "Featured", icon: "sparkles")
                        }
                        if bar.isTrending {
                            BadgePill(title: "Trending", icon: "flame.fill", tint: AppColors.accentSecondary)
                        }
                    }
                }

                Text(bar.neighborhood)
                    .labelStyle()
            }
            .padding(AppSpacing.lg)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    private func headerSection(bar: Bar) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(bar.name)
                .displayMediumStyle()
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: AppSpacing.md) {
                Label(bar.formattedRating, systemImage: "star.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accent)

                Text("·")
                    .foregroundStyle(AppColors.textTertiary)

                Text(bar.formattedDistance)
                    .captionStyle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func descriptionSection(bar: Bar) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: "About", subtitle: "The vibe")

            Text(bar.tagline)
                .bodyStyle()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func happyHourSection(_ happyHours: [HappyHour]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Happy Hour", subtitle: "When to go")

            VStack(spacing: AppSpacing.sm) {
                ForEach(happyHours) { happyHour in
                    PourCard {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(happyHour.dealDescription)
                                .headlineStyle()

                            HStack(spacing: AppSpacing.sm) {
                                Label(happyHour.timeRange, systemImage: "clock")
                                Label(happyHour.daysActive, systemImage: "calendar")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.accentMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private func cocktailSection(_ cocktails: [BarMenuCocktail], isPlaceholder: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Cocktails",
                subtitle: cocktails.isEmpty && !isPlaceholder ? "Menu coming soon" : "\(cocktails.count) on the menu"
            )

            if isPlaceholder && cocktails.isEmpty {
                ProgressView()
                    .tint(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
            } else if cocktails.isEmpty {
                ContentStateView(
                    icon: "wineglass",
                    title: "No cocktails listed",
                    message: "This bar hasn't added their menu yet."
                )
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(cocktails) { item in
                        NavigationLink(value: item.cocktail) {
                            CocktailRow(
                                cocktail: item.cocktail,
                                isSignature: item.isSignature
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func errorState(_ error: NetworkError) -> some View {
        ContentStateView(
            icon: "wifi.exclamationmark",
            title: "Couldn't load bar",
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
        BarDetailView(bar: MockDataService.trendingBars[0])
            .detailNavigation()
    }
    .environmentObject(SaveStore.shared)
    .preferredColorScheme(.dark)
}
