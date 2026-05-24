import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
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
                        featuredSection
                            .fadeInOnAppear(delay: 0.05)

                        trendingSection
                            .fadeInOnAppear(delay: 0.1)

                        happyHourSection
                            .fadeInOnAppear(delay: 0.15)

                        nearbySection
                            .fadeInOnAppear(delay: 0.2)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
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
    private var featuredSection: some View {
        if let cocktail = viewModel.featuredCocktail {
            NavigationLink(value: cocktail) {
                FeaturedCocktailCard(cocktail: cocktail)
            }
            .buttonStyle(.plain)
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

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Trending Bars",
                subtitle: "What everyone's talking about",
                actionTitle: "See all"
            ) {}

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
                                BarCard(bar: bar, style: .compact)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var happyHourSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Happy Hour",
                subtitle: "Deals happening now",
                actionTitle: "See all"
            ) {}

            if viewModel.happyHours.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                ContentStateView(
                    icon: "clock",
                    title: "No happy hours",
                    message: "Check back for deals near you."
                )
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.happyHours) { happyHour in
                        NavigationLink(value: happyHour.barID) {
                            HappyHourRow(happyHour: happyHour)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var nearbySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Nearby",
                subtitle: "Within walking distance",
                actionTitle: "Map"
            ) {}

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
