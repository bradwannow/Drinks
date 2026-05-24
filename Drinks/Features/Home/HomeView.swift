import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header
                        .fadeInOnAppear()

                    FeaturedCocktailCard(cocktail: viewModel.featuredCocktail)
                        .fadeInOnAppear(delay: 0.05)

                    trendingSection
                        .fadeInOnAppear(delay: 0.1)

                    happyHourSection
                        .fadeInOnAppear(delay: 0.15)

                    nearbySection
                        .fadeInOnAppear(delay: 0.2)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.bottom, AppSpacing.xxl)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .screenBackground()
            .toolbar(.hidden, for: .navigationBar)
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

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Trending Bars",
                subtitle: "What everyone's talking about",
                actionTitle: "See all"
            ) {}

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.trendingBars) { bar in
                        BarCard(bar: bar, style: .compact)
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

            VStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.happyHours) { happyHour in
                    HappyHourRow(happyHour: happyHour)
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

            VStack(spacing: AppSpacing.sm) {
                ForEach(viewModel.nearbyBars) { bar in
                    BarCard(bar: bar, style: .wide)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
