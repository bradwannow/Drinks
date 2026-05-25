import SwiftUI

struct MenuDetailView: View {
    @StateObject private var viewModel: MenuDetailViewModel

    init(menuVersionID: UUID) {
        _viewModel = StateObject(wrappedValue: MenuDetailViewModel(menuVersionID: menuVersionID))
    }

    init(detail: MenuVersionDetail) {
        _viewModel = StateObject(wrappedValue: MenuDetailViewModel(detail: detail))
    }

    var body: some View {
        Group {
            if let detail = viewModel.loadState.value {
                detailContent(detail)
            } else if viewModel.loadState.isLoading {
                ProgressView()
                    .tint(AppColors.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.loadState.error {
                ContentStateView(
                    icon: "wifi.exclamationmark",
                    title: "Couldn't load menu",
                    message: error.errorDescription ?? "Something went wrong.",
                    actionTitle: "Try again",
                    action: { Task { await viewModel.load() } },
                    style: .card
                )
                .padding(AppSpacing.screenPadding)
            }
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            if viewModel.loadState.value == nil {
                await viewModel.load()
            }
        }
    }

    private func detailContent(_ detail: MenuVersionDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                headerSection(detail.version)
                    .fadeInOnAppear()

                if !detail.images.isEmpty {
                    MenuImageCarousel(images: detail.images)
                        .fadeInOnAppear(delay: 0.05)
                }

                if let notes = detail.version.notes, !notes.isEmpty {
                    PourCard {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Contributor notes")
                                .labelStyle()
                            Text(notes)
                                .bodyStyle()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .fadeInOnAppear(delay: 0.08)
                }

                cocktailsSection(detail.cocktails)
                    .fadeInOnAppear(delay: 0.12)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.lg)
        }
        .scrollIndicators(.hidden)
    }

    private func headerSection(_ version: MenuVersion) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                if version.isCurrent {
                    BadgePill(title: "Current Menu", icon: "checkmark.seal.fill")
                }
                if version.isSeasonal {
                    BadgePill(title: "Seasonal", icon: "leaf.fill")
                }
            }

            Text(version.displayTitle)
                .displayMediumStyle()

            Text(version.displaySubtitle)
                .captionStyle()

            HStack(spacing: AppSpacing.md) {
                Label("\(version.imageCount) photos", systemImage: "photo.on.rectangle")
                Label("\(version.cocktailCount) drinks", systemImage: "wineglass")
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(AppColors.textTertiary)

            if let contributor = version.contributorName {
                Text("Captured by \(contributor)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.accentMuted)
            }
        }
    }

    private func cocktailsSection(_ cocktails: [MenuCocktailEntry]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Cocktails",
                subtitle: cocktails.isEmpty ? "Photos only — no text extracted" : "\(cocktails.count) on this menu"
            )

            if cocktails.isEmpty {
                ContentStateView(
                    icon: "text.viewfinder",
                    title: "No drinks extracted",
                    message: "Browse the menu photos above to see what's available."
                )
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(cocktails) { entry in
                        MenuCocktailEntryRow(entry: entry)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MenuDetailView(
            detail: MenuVersionDetail(
                version: MenuVersion(
                    id: UUID(),
                    menuID: UUID(),
                    barID: UUID(),
                    contributorID: nil,
                    contributorName: "Jordan",
                    seasonLabel: "Winter",
                    seasonMonth: 12,
                    isCurrent: true,
                    notes: "Rotating weekly — this was captured Friday night.",
                    ocrStatus: .completed,
                    uploadedAt: Date(),
                    createdAt: Date(),
                    versionNumber: 2,
                    imageCount: 2,
                    cocktailCount: 3,
                    coverImageURL: MockDataService.featuredCocktail.imageURL
                ),
                images: [],
                cocktails: [
                    MenuCocktailEntry(
                        id: UUID(),
                        menuVersionID: UUID(),
                        name: "Smoked Old Fashioned",
                        description: "Bourbon, maple, cherry wood smoke",
                        priceText: "$18",
                        sortOrder: 0,
                        ocrConfidence: 0.85,
                        isManuallyEdited: false,
                        cocktailID: nil,
                        createdAt: Date()
                    )
                ]
            )
        )
    }
    .preferredColorScheme(.dark)
}
