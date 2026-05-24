import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppSpacing.xl, pinnedViews: []) {
                    searchField
                        .fadeInOnAppear()

                    SearchFilterBar(
                        availableSpirits: viewModel.availableSpirits,
                        availableNeighborhoods: viewModel.availableNeighborhoods,
                        filters: $viewModel.filters,
                        onFilterChange: { viewModel.scheduleSearch() }
                    )
                    .fadeInOnAppear(delay: 0.03)

                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(message: errorMessage)
                            .fadeInOnAppear(delay: 0.05)
                    }

                    if viewModel.isShowingResults {
                        resultsContent
                            .fadeInOnAppear(delay: 0.08)
                    } else {
                        discoveryContent
                            .fadeInOnAppear(delay: 0.08)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
            .screenBackground()
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .detailNavigation()
            .task {
                await viewModel.loadDiscovery()
            }
            .onChange(of: viewModel.query) { _, _ in
                viewModel.scheduleSearch()
            }
        }
    }

    // MARK: - Search Field

    private var searchField: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textTertiary)

            TextField("Bars, cocktails, neighborhoods…", text: $viewModel.query)
                .foregroundStyle(AppColors.textPrimary)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    Task { await viewModel.performSearchImmediately() }
                }

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                .fill(AppColors.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous)
                        .strokeBorder(
                            isSearchFocused ? AppColors.accent.opacity(0.4) : AppColors.surfaceHighlight.opacity(0.5),
                            lineWidth: 1
                        )
                }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
    }

    // MARK: - Discovery

    @ViewBuilder
    private var discoveryContent: some View {
        if viewModel.isLoadingDiscovery && viewModel.recommendedCocktails.isEmpty {
            SearchLoadingView(message: "Building your discovery feed…")
        } else {
            if !viewModel.recentSearches.isEmpty {
                recentSearchesSection
            }

            trendingSearchesSection
            recommendedSection
            spiritsSection
            neighborhoodsSection
            collectionsSection
        }
    }

    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Recent",
                subtitle: "Pick up where you left off",
                actionTitle: "Clear",
                action: { viewModel.clearRecentSearches() }
            )

            FlowLayout(spacing: AppSpacing.sm) {
                ForEach(viewModel.recentSearches, id: \.self) { term in
                    FilterChip(title: term, icon: "clock.arrow.circlepath") {
                        viewModel.selectRecentSearch(term)
                    }
                }
            }
        }
    }

    private var trendingSearchesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Trending", subtitle: "Popular searches tonight")

            FlowLayout(spacing: AppSpacing.sm) {
                ForEach(viewModel.trendingSearches, id: \.self) { term in
                    FilterChip(title: term, icon: "flame.fill") {
                        applyTrendingTerm(term)
                    }
                }
            }
        }
    }

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Recommended", subtitle: "Cocktails you'll love")

            if viewModel.recommendedCocktails.isEmpty && !viewModel.isLoadingDiscovery {
                ContentStateView(
                    icon: "wineglass",
                    title: "No recommendations yet",
                    message: "Check back for curated pours."
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.recommendedCocktails) { cocktail in
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

    private var spiritsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "By Spirit", subtitle: "Explore by category")

            if viewModel.spiritCategories.isEmpty && !viewModel.isLoadingDiscovery {
                ContentStateView(
                    icon: "drop.fill",
                    title: "No spirits yet",
                    message: "Spirit categories will appear here."
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.spiritCategories) { category in
                            Button {
                                viewModel.selectSpirit(category.name)
                            } label: {
                                DiscoveryTile(
                                    title: category.name,
                                    subtitle: "\(category.cocktailCount) cocktails",
                                    imageURL: category.imageURL,
                                    icon: "drop.fill"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var neighborhoodsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "By Neighborhood", subtitle: "Chicago's best bar scenes")

            if viewModel.neighborhoodCategories.isEmpty && !viewModel.isLoadingDiscovery {
                ContentStateView(
                    icon: "mappin.circle",
                    title: "No neighborhoods yet",
                    message: "Neighborhood guides will appear here."
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(viewModel.neighborhoodCategories) { category in
                            Button {
                                viewModel.selectNeighborhood(category.name)
                            } label: {
                                DiscoveryTile(
                                    title: category.name,
                                    subtitle: "\(category.barCount) bars",
                                    imageURL: category.imageURL,
                                    icon: "mappin.circle.fill"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Collections", subtitle: "Curated for tonight")

            if viewModel.featuredCollections.isEmpty && !viewModel.isLoadingDiscovery {
                ContentStateView(
                    icon: "square.stack.3d.up",
                    title: "No collections yet",
                    message: "Featured collections are on the way."
                )
            } else {
                VStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.featuredCollections) { collection in
                        Button {
                            viewModel.applyCollection(collection)
                        } label: {
                            FeaturedCollectionCard(collection: collection)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Results

    @ViewBuilder
    private var resultsContent: some View {
        if viewModel.isSearching {
            SearchLoadingView(message: "Searching Chicago…")
        } else if viewModel.results.isEmpty {
            ContentStateView(
                icon: "magnifyingglass",
                title: "No results",
                message: emptyResultsMessage,
                actionTitle: viewModel.filters.isActive ? "Clear filters" : nil,
                action: viewModel.filters.isActive ? {
                    viewModel.filters.clear()
                    Task { await viewModel.performSearchImmediately() }
                } : nil,
                style: .card
            )
        } else {
            if !viewModel.results.neighborhoods.isEmpty {
                quickMatchSection(
                    title: "Neighborhoods",
                    items: viewModel.results.neighborhoods,
                    icon: "mappin.circle.fill"
                ) { neighborhood in
                    viewModel.selectNeighborhood(neighborhood)
                }
            }

            if !viewModel.results.spirits.isEmpty {
                quickMatchSection(
                    title: "Spirits",
                    items: viewModel.results.spirits,
                    icon: "drop.fill"
                ) { spirit in
                    viewModel.selectSpirit(spirit)
                }
            }

            if !viewModel.results.cocktails.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(
                        title: "Cocktails",
                        subtitle: "\(viewModel.results.cocktails.count) found"
                    )

                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.results.cocktails) { cocktail in
                            NavigationLink(value: cocktail) {
                                CocktailRow(cocktail: cocktail, showsChevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if !viewModel.results.bars.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    SectionHeader(
                        title: "Bars",
                        subtitle: "\(viewModel.results.bars.count) found"
                    )

                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.results.bars) { bar in
                            NavigationLink(value: bar) {
                                BarCard(bar: bar, style: .wide)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func quickMatchSection(
        title: String,
        items: [String],
        icon: String,
        action: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: title, subtitle: "Quick matches")

            FlowLayout(spacing: AppSpacing.sm) {
                ForEach(items, id: \.self) { item in
                    FilterChip(title: item, icon: icon) {
                        action(item)
                    }
                }
            }
        }
    }

    private var emptyResultsMessage: String {
        if viewModel.filters.isActive {
            return "Nothing matched your filters. Try adjusting them or searching for something else."
        }
        return "We couldn't find anything for \"\(viewModel.query)\". Try a different search or browse below."
    }

    private func applyTrendingTerm(_ term: String) {
        let lowered = term.lowercased()
        if lowered == "happy hour" {
            viewModel.filters = SearchFilters(happyHourNow: true)
            viewModel.query = ""
            Task { await viewModel.performSearchImmediately() }
        } else if lowered == "seasonal" {
            viewModel.filters = SearchFilters(seasonalOnly: true)
            viewModel.query = ""
            Task { await viewModel.performSearchImmediately() }
        } else if viewModel.availableSpirits.contains(where: { $0.localizedCaseInsensitiveCompare(term) == .orderedSame }) {
            viewModel.query = ""
            viewModel.selectSpirit(term)
        } else if viewModel.availableNeighborhoods.contains(where: { $0.localizedCaseInsensitiveCompare(term) == .orderedSame }) {
            viewModel.query = ""
            viewModel.selectNeighborhood(term)
        } else {
            viewModel.selectTrendingSearch(term)
        }
    }

    private func errorBanner(message: String) -> some View {
        ContentStateView(
            icon: "wifi.exclamationmark",
            title: "Couldn't load discovery",
            message: message,
            actionTitle: "Try again",
            action: {
                Task { await viewModel.loadDiscovery() }
            },
            style: .card
        )
    }
}

private struct SearchLoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .tint(AppColors.accent)
                .scaleEffect(1.1)

            Text(message)
                .captionStyle()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xxl)
    }
}

#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
