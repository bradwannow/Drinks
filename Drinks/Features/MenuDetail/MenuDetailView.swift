import SwiftUI

struct MenuDetailView: View {
    @StateObject private var viewModel: MenuDetailViewModel

    init(menuVersionID: UUID, previousVersionID: UUID? = nil) {
        _viewModel = StateObject(wrappedValue: MenuDetailViewModel(menuVersionID: menuVersionID))
        self.previousVersionID = previousVersionID
    }

    init(detail: MenuVersionDetail) {
        _viewModel = StateObject(wrappedValue: MenuDetailViewModel(detail: detail))
        self.previousVersionID = nil
    }

    private let previousVersionID: UUID?

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
                    action: { Task { await viewModel.load(previousVersionID: previousVersionID) } },
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
                await viewModel.load(previousVersionID: previousVersionID)
            }
        }
    }

    private func detailContent(_ detail: MenuVersionDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                headerSection(detail.version)
                    .fadeInOnAppear()

                FreshnessBadgeStrip(badges: detail.version.freshnessBadges())
                    .fadeInOnAppear(delay: 0.03)

                if !detail.images.isEmpty {
                    MenuImageCarousel(images: detail.images)
                        .fadeInOnAppear(delay: 0.05)
                }

                if detail.version.isCurrent {
                    MenuValidationBar(
                        version: detail.version,
                        viewerState: detail.viewerState,
                        isProcessing: viewModel.isValidating,
                        onConfirm: { Task { await viewModel.confirmMenu() } },
                        onReportOutdated: { Task { await viewModel.reportOutdated() } }
                    )
                    .fadeInOnAppear(delay: 0.06)
                }

                if let comparison = detail.comparison, comparison.hasChanges {
                    MenuDiffSection(comparison: comparison)
                        .fadeInOnAppear(delay: 0.08)
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
                    .fadeInOnAppear(delay: 0.1)
                }

                cocktailsSection(detail.cocktails, comparison: detail.comparison)
                    .fadeInOnAppear(delay: 0.12)

                if let error = viewModel.validationError {
                    Text(error.errorDescription ?? "Action failed")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.accentSecondary)
                }
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
                if version.isCommunityVerified {
                    BadgePill(title: "Verified", icon: "checkmark.seal.fill", tint: AppColors.accent)
                }
            }

            Text(version.displayTitle)
                .displayMediumStyle()

            Text(version.lastUpdatedLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.accentMuted)

            Text(version.displaySubtitle)
                .captionStyle()

            HStack(spacing: AppSpacing.md) {
                Label("\(version.imageCount) photos", systemImage: "photo.on.rectangle")
                Label("\(version.cocktailCount) drinks", systemImage: "wineglass")
                if version.confirmationCount > 0 {
                    Label("\(version.confirmationCount) confirmed", systemImage: "person.2.fill")
                }
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

    private func cocktailsSection(_ cocktails: [MenuCocktailEntry], comparison: MenuComparison?) -> some View {
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
                        MenuCocktailEntryRow(
                            entry: entry,
                            changeKind: changeKind(for: entry.name, comparison: comparison)
                        )
                    }
                }
            }
        }
    }

    private func changeKind(for name: String, comparison: MenuComparison?) -> MenuCocktailChangeKind? {
        guard let comparison else { return nil }
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if comparison.added.contains(where: { $0.lowercased() == normalized }) { return .added }
        if comparison.seasonalReturns.contains(where: { $0.lowercased() == normalized }) { return .seasonalReturn }
        return nil
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
                    coverImageURL: MockDataService.featuredCocktail.imageURL,
                    confirmationCount: 3,
                    confidenceScore: 0.71,
                    isOutdated: false
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
                ],
                comparison: MenuComparison(added: ["Smoked Old Fashioned"], removed: [], seasonalReturns: [])
            )
        )
    }
    .preferredColorScheme(.dark)
}
