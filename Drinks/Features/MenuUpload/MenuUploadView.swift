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
                    case .preview:
                        previewStep
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
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(MenuUploadStep.allCases, id: \.self) { step in
                    Capsule()
                        .fill(step.rawValue <= viewModel.step.rawValue ? AppColors.accent : AppColors.surfaceHighlight)
                        .frame(height: 3)
                }
            }

            Text(viewModel.step.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.accentMuted)
                .textCase(.uppercase)
                .tracking(0.8)
        }
    }

    private var photosStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Menu Photos")
                    .displayMediumStyle()
                Text("Photograph the full cocktail menu — drag to reorder pages after selecting.")
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
            .onChange(of: viewModel.selectedItems) { _, _ in
                Task { await viewModel.loadSelectedPhotos() }
            }

            if !viewModel.draftImages.isEmpty {
                MenuImageReorderStrip(
                    images: $viewModel.draftImages,
                    onMove: viewModel.moveImage,
                    onRemove: viewModel.removeImage
                )
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

            if viewModel.isProcessingOCR {
                PourCard {
                    HStack(spacing: AppSpacing.sm) {
                        ProgressView().tint(AppColors.accent)
                        Text("Reading menu text...")
                            .captionStyle()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
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
                if viewModel.lowConfidenceCount > 0 {
                    Text("\(viewModel.lowConfidenceCount) items need verification — shown first.")
                        .bodyStyle()
                } else {
                    Text("Quick-edit names and prices before publishing.")
                        .bodyStyle()
                }
            }

            if viewModel.cocktails.isEmpty {
                ContentStateView(
                    icon: "text.viewfinder",
                    title: "No cocktails detected",
                    message: "Add drinks manually or continue with photos only."
                )
            } else {
                List {
                    ForEach($viewModel.cocktails) { $cocktail in
                        MenuCocktailEditRow(cocktail: $cocktail) {
                            viewModel.removeCocktail(id: cocktail.id)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    }
                    .onMove(perform: viewModel.moveCocktail)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .frame(minHeight: CGFloat(viewModel.cocktails.count) * 130)
            }

            HStack(spacing: AppSpacing.md) {
                Button(action: { viewModel.addCocktail() }) {
                    Label("Add drink", systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.accent)
                }
                .buttonStyle(.plain)

                EditButton()
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .fadeInOnAppear(delay: 0.05)
    }

    private var previewStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Preview Before Publish")
                    .displayMediumStyle()
                Text("This is how your menu will appear in the archive.")
                    .bodyStyle()
            }

            PourCard(padding: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    if let firstImage = viewModel.previewImages.first {
                        Image(uiImage: firstImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        HStack(spacing: AppSpacing.xs) {
                            if viewModel.isCurrent {
                                BadgePill(title: "Current Menu", icon: "checkmark.seal.fill")
                            }
                            if !viewModel.seasonLabel.isEmpty {
                                BadgePill(title: viewModel.seasonLabel, icon: "leaf.fill")
                            }
                        }

                        Text(viewModel.bar.name)
                            .headlineStyle()

                        HStack(spacing: AppSpacing.md) {
                            Label("\(viewModel.draftImages.count) photos", systemImage: "photo.on.rectangle")
                            Label("\(viewModel.cocktails.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count) drinks", systemImage: "wineglass")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.textTertiary)
                    }
                    .padding(AppSpacing.md)
                }
            }

            if !viewModel.cocktails.filter({ !$0.name.isEmpty }).isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Extracted cocktails")
                        .labelStyle()

                    ForEach(viewModel.cocktails.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.prefix(8)) { cocktail in
                        HStack {
                            Text(cocktail.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.textPrimary)
                            Spacer()
                            if let price = cocktail.priceText {
                                Text(price)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.accent)
                            }
                        }
                        .padding(.vertical, AppSpacing.xxs)
                    }
                }
            }

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
            if viewModel.step == .preview {
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
                        if viewModel.isProcessingOCR && viewModel.step == .photos {
                            ProgressView().tint(AppColors.background)
                        } else {
                            Text(viewModel.step == .review ? "Preview" : "Continue")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.accent)
                    .foregroundStyle(AppColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardRadius, style: .continuous))
                }
                .disabled(viewModel.step == .photos && viewModel.draftImages.isEmpty)
                .opacity(viewModel.step == .photos && viewModel.draftImages.isEmpty ? 0.5 : 1)
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
