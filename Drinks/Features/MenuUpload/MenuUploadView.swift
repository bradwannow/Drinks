import PhotosUI
import SwiftUI

struct MenuUploadView: View {
    @StateObject private var viewModel: MenuUploadViewModel
    @Environment(\.dismiss) private var dismiss

    init(bar: Bar) {
        _viewModel = StateObject(wrappedValue: MenuUploadViewModel(bar: bar))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    stepIndicator
                        .fadeInOnAppear()

                    switch viewModel.step {
                    case .photos:
                        photosStep
                    case .details:
                        detailsStep
                    case .review:
                        reviewStep
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.lg)
            }
            .scrollIndicators(.hidden)
            .screenBackground()
            .navigationTitle("Capture Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
            .onChange(of: viewModel.completedMenu) { _, menu in
                if menu != nil { dismiss() }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var stepIndicator: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(MenuUploadStep.allCases, id: \.self) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.step.rawValue ? AppColors.accent : AppColors.surfaceHighlight)
                    .frame(height: 3)
            }
        }
    }

    private var photosStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Menu Photos")
                    .displayMediumStyle()
                Text("Photograph the full cocktail menu — multiple pages welcome. We'll extract drink names automatically.")
                    .bodyStyle()
            }

            PhotosPicker(
                selection: $viewModel.selectedItems,
                maxSelectionCount: 8,
                matching: .images
            ) {
                PourCard {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 32))
                            .foregroundStyle(AppColors.accent)

                        Text(viewModel.selectedItems.isEmpty ? "Add menu photos" : "\(viewModel.selectedItems.count) photos selected")
                            .headlineStyle()

                        Text("Tap to choose from your library")
                            .captionStyle()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.lg)
                }
            }

            if !viewModel.previewImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(Array(viewModel.previewImages.enumerated()), id: \.offset) { _, image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
                        }
                    }
                }
            }
        }
        .fadeInOnAppear(delay: 0.05)
    }

    private var detailsStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Menu Details")
                    .displayMediumStyle()
                Text("Help others know when this menu was live.")
                    .bodyStyle()
            }

            PourCard {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text("Season / rotation")
                        .labelStyle()

                    FlowLayout(spacing: AppSpacing.xs) {
                        ForEach(MenuSeasonUtility.seasonPresets, id: \.self) { preset in
                            FilterChip(
                                title: preset,
                                isSelected: viewModel.seasonLabel == preset
                            ) {
                                viewModel.seasonLabel = preset
                            }
                        }
                    }

                    TextField("Custom label (optional)", text: $viewModel.seasonLabel)
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(AppSpacing.sm)
                        .background(AppColors.backgroundElevated)
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.sm, style: .continuous))
                }
            }

            PourCard {
                Toggle(isOn: $viewModel.isCurrent) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Mark as current menu")
                            .headlineStyle()
                        Text("Replaces any existing current menu for this bar")
                            .captionStyle()
                    }
                }
                .tint(AppColors.accent)
            }

            PourCard {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Notes (optional)")
                        .labelStyle()
                    TextField("e.g. Weekly rotation, bartender's choice section...", text: $viewModel.notes, axis: .vertical)
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(3...6)
                }
            }
        }
        .fadeInOnAppear(delay: 0.05)
    }

    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Review Cocktails")
                    .displayMediumStyle()
                Text("OCR isn't perfect — edit names, fix typos, or remove items that aren't drinks.")
                    .bodyStyle()
            }

            if viewModel.isProcessingOCR {
                HStack(spacing: AppSpacing.sm) {
                    ProgressView().tint(AppColors.accent)
                    Text("Reading menu text...")
                        .captionStyle()
                }
            } else if viewModel.cocktails.isEmpty {
                ContentStateView(
                    icon: "text.viewfinder",
                    title: "No cocktails detected",
                    message: "You can add drinks manually or submit photos-only for now."
                )
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach($viewModel.cocktails) { $cocktail in
                        MenuCocktailEditRow(cocktail: $cocktail) {
                            viewModel.removeCocktail(id: cocktail.id)
                        }
                    }
                }
            }

            Button(action: { viewModel.addCocktail() }) {
                Label("Add cocktail manually", systemImage: "plus.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
            .buttonStyle(.plain)

            if let error = viewModel.uploadError {
                Text(error.errorDescription ?? "Upload failed")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.accentSecondary)
            }
        }
        .fadeInOnAppear(delay: 0.05)
    }

    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: AppSpacing.sm) {
            if viewModel.step == .review {
                Button {
                    Task { await viewModel.submit() }
                } label: {
                    Group {
                        if viewModel.isUploading {
                            ProgressView().tint(AppColors.background)
                        } else {
                            Text("Publish Menu")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.accent)
                    .foregroundStyle(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
                }
                .disabled(!viewModel.canSubmit)
                .opacity(viewModel.canSubmit ? 1 : 0.5)
            } else {
                Button {
                    Task { await viewModel.advanceStep() }
                } label: {
                    Group {
                        if viewModel.isProcessingOCR {
                            ProgressView().tint(AppColors.background)
                        } else {
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.accent)
                    .foregroundStyle(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
                }
                .disabled(viewModel.step == .photos && viewModel.selectedItems.isEmpty)
                .opacity(viewModel.step == .photos && viewModel.selectedItems.isEmpty ? 0.5 : 1)
            }

            if viewModel.step != .photos {
                Button("Back") { viewModel.goBack() }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.md)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    MenuUploadView(bar: MockDataService.trendingBars[0])
}
