import SwiftUI

struct BarDetailView: View {
    @StateObject private var viewModel: BarDetailViewModel
    @EnvironmentObject private var saveStore: SaveStore
    @State private var showMenuUpload = false

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
                    BarDetailContent(
                        bar: bar,
                        cocktails: [],
                        happyHours: [],
                        updates: [],
                        menuArchive: BarMenuArchive(
                            currentMenu: nil,
                            previousMenus: [],
                            recentlyAddedCocktails: [],
                            seasonalRotations: []
                        )
                    ),
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
                    HStack(spacing: AppSpacing.md) {
                        Button {
                            showMenuUpload = true
                        } label: {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(AppColors.accent)
                        }

                        SaveButton(isSaved: saveStore.isBarSaved(bar.id)) {
                            Task { await saveStore.toggleBar(bar.id) }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showMenuUpload) {
            if let bar = viewModel.displayBar {
                MenuUploadView(bar: bar)
                    .onDisappear {
                        Task { await viewModel.load() }
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

                    FreshnessBadgeStrip(badges: FreshnessUtility.badges(for: content.bar))
                        .fadeInOnAppear(delay: 0.06)

                    currentMenuSection(content.menuArchive, isPlaceholder: isPlaceholder)
                        .fadeInOnAppear(delay: 0.07)

                    if !content.menuArchive.recentlyAddedCocktails.isEmpty {
                        recentlyAddedSection(content.menuArchive.recentlyAddedCocktails)
                            .fadeInOnAppear(delay: 0.08)
                    }

                    if !content.menuArchive.seasonalRotations.isEmpty {
                        seasonalRotationsSection(content.menuArchive.seasonalRotations)
                            .fadeInOnAppear(delay: 0.09)
                    }

                    if !content.updates.isEmpty {
                        updatesSection(content.updates, cocktails: content.cocktails)
                            .fadeInOnAppear(delay: 0.1)
                    }

                    descriptionSection(bar: content.bar)
                        .fadeInOnAppear(delay: 0.11)

                    if !content.happyHours.isEmpty {
                        happyHourSection(content.happyHours)
                            .fadeInOnAppear(delay: 0.12)
                    }

                    if !content.menuArchive.previousMenus.isEmpty {
                        previousMenusSection(content.menuArchive.previousMenus)
                            .fadeInOnAppear(delay: 0.13)
                    }

                    cocktailSection(content.cocktails, menuArchive: content.menuArchive, isPlaceholder: isPlaceholder)
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

    private func currentMenuSection(_ archive: BarMenuArchive, isPlaceholder: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Current Menu",
                subtitle: "Live cocktail list",
                actionTitle: "Capture",
                action: { showMenuUpload = true }
            )

            if isPlaceholder && archive.currentMenu == nil {
                ProgressView()
                    .tint(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
            } else if let currentMenu = archive.currentMenu {
                NavigationLink(value: currentMenu) {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        if !currentMenu.images.isEmpty {
                            MenuImageCarousel(images: currentMenu.images, height: 280)
                        }

                        MenuTimelineCard(version: currentMenu.version)
                    }
                }
                .buttonStyle(.plain)
            } else {
                PourCard {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Label("No menu captured yet", systemImage: "doc.text.viewfinder")
                            .headlineStyle()

                        Text("Be the first to photograph this bar's rotating cocktail menu.")
                            .bodyStyle()

                        Button("Upload menu photos") {
                            showMenuUpload = true
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                        .padding(.top, AppSpacing.xs)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func recentlyAddedSection(_ entries: [MenuCocktailEntry]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Recently Added", subtitle: "New on the current menu")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(entries) { entry in
                        PourCard(padding: AppSpacing.md) {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(entry.name)
                                    .headlineStyle()
                                    .lineLimit(2)

                                if !entry.description.isEmpty {
                                    Text(entry.description)
                                        .captionStyle()
                                        .lineLimit(2)
                                }

                                if let price = entry.priceText {
                                    Text(price)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(AppColors.accent)
                                }
                            }
                            .frame(width: 180, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private func seasonalRotationsSection(_ rotations: [MenuVersion]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Seasonal Rotations", subtitle: "Archived seasonal menus")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(rotations) { version in
                        NavigationLink(value: MenuVersionRoute(id: version.id)) {
                            PourCard(padding: 0) {
                                VStack(alignment: .leading, spacing: 0) {
                                    ZStack {
                                        if let cover = version.coverImageURL {
                                            AsyncImageView(url: cover, cornerRadius: 0)
                                        } else {
                                            AppColors.surfaceHighlight
                                            Image(systemName: "leaf.fill")
                                                .foregroundStyle(AppColors.accentMuted)
                                        }
                                    }
                                    .frame(width: 160, height: 100)

                                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                        Text(version.displayTitle)
                                            .headlineStyle()
                                            .lineLimit(1)
                                        Text("\(version.cocktailCount) drinks")
                                            .captionStyle()
                                    }
                                    .padding(AppSpacing.sm)
                                }
                                .frame(width: 160, alignment: .leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func previousMenusSection(_ menus: [MenuVersion]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Previous Menus", subtitle: "Menu history timeline")

            VStack(spacing: AppSpacing.sm) {
                ForEach(menus.prefix(5)) { version in
                    NavigationLink(value: MenuVersionRoute(id: version.id)) {
                        MenuTimelineCard(version: version)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func updatesSection(_ updates: [BarUpdate], cocktails: [BarMenuCocktail]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "What's New", subtitle: "Updates from the bar")

            VStack(spacing: AppSpacing.sm) {
                ForEach(updates) { update in
                    if let cocktailID = update.cocktailID,
                       let menuItem = cocktails.first(where: { $0.cocktail.id == cocktailID }) {
                        NavigationLink(value: menuItem.cocktail) {
                            BarUpdateRow(update: update)
                        }
                        .buttonStyle(.plain)
                    } else {
                        BarUpdateRow(update: update)
                    }
                }
            }
        }
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

    @ViewBuilder
    private func cocktailSection(
        _ cocktails: [BarMenuCocktail],
        menuArchive: BarMenuArchive,
        isPlaceholder: Bool
    ) -> some View {
        let menuCocktails = menuArchive.currentMenu?.cocktails ?? []
        let hasMenuEntries = !menuCocktails.isEmpty

        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: hasMenuEntries ? "Menu Cocktails" : "Cocktails",
                subtitle: hasMenuEntries
                    ? "\(menuCocktails.count) from captured menu"
                    : cocktails.isEmpty && !isPlaceholder ? "Menu coming soon" : "\(cocktails.count) on the menu"
            )

            if isPlaceholder && cocktails.isEmpty && !hasMenuEntries {
                ProgressView()
                    .tint(AppColors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
            } else if hasMenuEntries {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(menuCocktails) { entry in
                        MenuCocktailEntryRow(entry: entry)
                    }
                }
            } else if cocktails.isEmpty {
                ContentStateView(
                    icon: "wineglass",
                    title: "No cocktails listed",
                    message: "Capture a menu photo to archive this bar's rotating drinks."
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
