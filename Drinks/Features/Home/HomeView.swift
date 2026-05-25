import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header
                        .fadeInOnAppear()

                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(message: errorMessage)
                            .fadeInOnAppear(delay: 0.03)
                    }

                    if viewModel.isLoading && !viewModel.hasLoadedContent {
                        HomeLoadingOverlay()
                            .fadeInOnAppear(delay: 0.05)
                    } else if viewModel.shouldShowContentSections {
                        activityFeedSection
                            .fadeInOnAppear(delay: 0.04)

                        menusUpdatedTonightSection
                            .fadeInOnAppear(delay: 0.045)

                        recentlyUpdatedMenusSection
                            .fadeInOnAppear(delay: 0.047)

                        newSeasonalMenusSection
                            .fadeInOnAppear(delay: 0.049)

                        featuredSection
                            .fadeInOnAppear(delay: 0.06)

                        recentlyAddedSection
                            .fadeInOnAppear(delay: 0.08)

                        trendingTonightSection
                            .fadeInOnAppear(delay: 0.1)

                        activeHappyHourSection
                            .fadeInOnAppear(delay: 0.12)

                        seasonalSection
                            .fadeInOnAppear(delay: 0.14)

                        trendingBarsSection
                            .fadeInOnAppear(delay: 0.16)

                        nearbySection
                            .fadeInOnAppear(delay: 0.18)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .screenBackground()
            .toolbar(.hidden, for: .navigationBar)
            .detailNavigation()
            .task {
                await viewModel.load()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(greeting)
                .captionStyle()

            Text("Tonight's Pour")
                .displayMediumStyle()
        }
        .padding(.top, AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    @ViewBuilder
    private var activityFeedSection: some View {
        if !viewModel.activityFeed.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SectionHeader(
                    title: "Live Now",
                    subtitle: "What's changing tonight"
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.activityFeed) { entry in
                            activityLink(for: entry)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var menusUpdatedTonightSection: some View {
        menuDiscoverySection(
            title: "Menus Updated Tonight",
            subtitle: "Fresh captures from the floor",
            items: viewModel.menusUpdatedTonight
        )
    }

    @ViewBuilder
    private var recentlyUpdatedMenusSection: some View {
        menuDiscoverySection(
            title: "Recently Updated Menus",
            subtitle: "Living cocktail programs",
            items: viewModel.recentlyUpdatedMenus
        )
    }

    @ViewBuilder
    private var newSeasonalMenusSection: some View {
        menuDiscoverySection(
            title: "New Seasonal Menus",
            subtitle: "Rotations worth exploring",
            items: viewModel.newSeasonalMenus
        )
    }

    @ViewBuilder
    private func menuDiscoverySection(title: String, subtitle: String, items: [MenuDiscoveryItem]) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SectionHeader(title: title, subtitle: subtitle)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(items) { item in
                            NavigationLink(value: MenuVersionRoute(id: item.version.id)) {
                                MenuDiscoveryCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func activityLink(for entry: ActivityFeedEntry) -> some View {
        if let cocktail = entry.cocktail {
            NavigationLink(value: cocktail) {
                ActivityFeedCard(entry: entry)
            }
            .buttonStyle(.plain)
        } else if let bar = entry.bar {
            NavigationLink(value: bar) {
                ActivityFeedCard(entry: entry)
            }
            .buttonStyle(.plain)
        } else if let barID = entry.item.barID {
            NavigationLink(value: BarRoute(id: barID)) {
                ActivityFeedCard(entry: entry)
            }
            .buttonStyle(.plain)
        } else {
            ActivityFeedCard(entry: entry)
        }
    }

    @ViewBuilder
    private var featuredSection: some View {
        if let cocktail = viewModel.featuredCocktail {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                FreshnessBadgeStrip(badges: FreshnessUtility.badges(for: cocktail))

                NavigationLink(value: cocktail) {
                    FeaturedCocktailCard(cocktail: cocktail)
                }
                .buttonStyle(.plain)
            }
            .overlay(alignment: .topTrailing) {
                if viewModel.isLoading {
                    loadingBadge
                        .padding(AppSpacing.md)
                }
            }
        } else if !viewModel.isLoading && viewModel.errorMessage == nil {
            ContentStateView(
                icon: "sparkles",
                title: "No featured pour",
                message: "We're lining up tonight's signature cocktail.",
                style: .card
            )
        }
    }

    private var recentlyAddedSection: some View {
        cocktailCarouselSection(
            title: "Recently Added",
            subtitle: "Fresh pours on the scene",
            cocktails: viewModel.recentlyAdded,
            emptyIcon: "plus.circle",
            emptyTitle: "Nothing new yet",
            emptyMessage: "New cocktails will land here first."
        )
    }

    private var trendingTonightSection: some View {
        cocktailCarouselSection(
            title: "Trending Tonight",
            subtitle: "What everyone's ordering",
            cocktails: viewModel.trendingTonight,
            emptyIcon: "flame.fill",
            emptyTitle: "Quiet tonight",
            emptyMessage: "Trending pours will heat up here."
        )
    }

    private var seasonalSection: some View {
        cocktailCarouselSection(
            title: "Seasonal Right Now",
            subtitle: "Rotating menus for the moment",
            cocktails: viewModel.seasonalNow,
            emptyIcon: "leaf.fill",
            emptyTitle: "No seasonal pours",
            emptyMessage: "Seasonal menus will appear here."
        )
    }

    private func cocktailCarouselSection(
        title: String,
        subtitle: String,
        cocktails: [Cocktail],
        emptyIcon: String,
        emptyTitle: String,
        emptyMessage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: title, subtitle: subtitle)

            if cocktails.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                ContentStateView(icon: emptyIcon, title: emptyTitle, message: emptyMessage)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(cocktails) { cocktail in
                            NavigationLink(value: cocktail) {
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    FreshnessBadgeStrip(
                                        badges: FreshnessUtility.badges(for: cocktail),
                                        maxVisible: 2
                                    )
                                    RelatedCocktailCard(cocktail: cocktail)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var activeHappyHourSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Happy Hour Happening Now",
                subtitle: "Deals live right this minute"
            )

            if viewModel.activeHappyHours.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                ContentStateView(
                    icon: "clock",
                    title: "No active happy hours",
                    message: "Check back when the deals start."
                )
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.activeHappyHours) { happyHour in
                        NavigationLink(value: BarRoute(id: happyHour.barID)) {
                            HappyHourRow(happyHour: happyHour, showsStatus: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var trendingBarsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Trending Bars",
                subtitle: "Hot spots across Chicago"
            )

            if viewModel.trendingBars.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                ContentStateView(
                    icon: "building.2",
                    title: "No trending bars",
                    message: "New spots will appear here soon."
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.trendingBars) { bar in
                            NavigationLink(value: bar) {
                                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                    FreshnessBadgeStrip(
                                        badges: FreshnessUtility.badges(for: bar),
                                        maxVisible: 2
                                    )
                                    BarCard(bar: bar, style: .compact)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Nearby",
                subtitle: "Within walking distance"
            )

            if viewModel.nearbyBars.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                ContentStateView(
                    icon: "location",
                    title: "Nothing nearby",
                    message: "Bars in your area will show up here."
                )
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.nearbyBars) { bar in
                        NavigationLink(value: bar) {
                            BarCard(bar: bar, style: .wide)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func errorBanner(message: String) -> some View {
        ContentStateView(
            icon: "wifi.exclamationmark",
            title: "Couldn't load tonight's picks",
            message: message,
            actionTitle: "Try again",
            action: {
                Task { await viewModel.refresh() }
            },
            style: .card
        )
    }

    private var loadingBadge: some View {
        ProgressView()
            .tint(AppColors.accent)
            .padding(AppSpacing.sm)
            .background(.ultraThinMaterial, in: Circle())
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
