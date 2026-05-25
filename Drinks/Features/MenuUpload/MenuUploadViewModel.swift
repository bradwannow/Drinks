import Foundation
import PhotosUI
import SwiftUI

enum MenuUploadStep: Int, CaseIterable {
    case photos
    case details
    case review
    case preview

    var title: String {
        switch self {
        case .photos: return "Photos"
        case .details: return "Details"
        case .review: return "Review"
        case .preview: return "Preview"
        }
    }
}

@MainActor
final class MenuUploadViewModel: ObservableObject {
    @Published var step: MenuUploadStep = .photos
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var draftImages: [DraftMenuImage] = []
    @Published var ocrTexts: [String] = []
    @Published var cocktails: [DraftMenuCocktail] = []
    @Published var seasonLabel: String = MenuSeasonUtility.currentSeasonLabel()
    @Published var seasonMonth: Int = MenuSeasonUtility.currentMonth()
    @Published var isCurrent: Bool = true
    @Published var notes: String = ""
    @Published var isEditingCocktails = false
    @Published private(set) var isProcessingOCR = false
    @Published private(set) var isUploading = false
    @Published private(set) var uploadError: NetworkError?
    @Published private(set) var completedMenu: MenuVersionDetail?

    let bar: Bar

    private let menuService: MenuService

    init(bar: Bar, menuService: MenuService = .shared) {
        self.bar = bar
        self.menuService = menuService
    }

    var imageData: [Data] {
        draftImages.map(\.data)
    }

    var previewImages: [UIImage] {
        draftImages.map(\.image)
    }

    var canAdvanceFromPhotos: Bool {
        !draftImages.isEmpty && !isProcessingOCR
    }

    var canSubmit: Bool {
        !draftImages.isEmpty && !isUploading
    }

    var lowConfidenceCount: Int {
        cocktails.filter { $0.hasLowConfidence }.count
    }

    var sortedCocktailsForReview: [DraftMenuCocktail] {
        cocktails.sorted { lhs, rhs in
            if lhs.hasLowConfidence != rhs.hasLowConfidence {
                return lhs.hasLowConfidence
            }
            return false
        }
    }

    func loadSelectedPhotos() async {
        var loaded: [DraftMenuImage] = []

        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let compressed = StorageService.compressedJPEGData(from: data),
               let image = UIImage(data: compressed) {
                loaded.append(DraftMenuImage(image: image, data: compressed))
            }
        }

        draftImages = loaded
    }

    func runOCR() async {
        guard !imageData.isEmpty else { return }
        isProcessingOCR = true
        defer { isProcessingOCR = false }

        var texts: [String] = []
        for data in imageData {
            let text = (try? await MenuOCRService.extractText(from: data)) ?? ""
            texts.append(text)
        }
        ocrTexts = texts

        cocktails = await MenuOCRService.parseCocktails(from: imageData)
        sortCocktailsForReview()
        if cocktails.isEmpty {
            cocktails = [DraftMenuCocktail(name: "", description: "", isManuallyEdited: true)]
        }
    }

    func advanceStep() async {
        switch step {
        case .photos:
            await loadSelectedPhotos()
            await runOCR()
            step = .details
        case .details:
            step = .review
        case .review:
            step = .preview
        case .preview:
            break
        }
    }

    func goBack() {
        guard let previous = MenuUploadStep(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    func removeImage(id: UUID) {
        draftImages.removeAll { $0.id == id }
        selectedItems = []
    }

    func moveImage(from source: UUID, to destination: UUID) {
        guard
            let fromIndex = draftImages.firstIndex(where: { $0.id == source }),
            let toIndex = draftImages.firstIndex(where: { $0.id == destination }),
            fromIndex != toIndex
        else { return }

        let item = draftImages.remove(at: fromIndex)
        draftImages.insert(item, at: toIndex)
    }

    func moveCocktail(from source: IndexSet, to destination: Int) {
        cocktails.move(fromOffsets: source, toOffset: destination)
    }

    func addCocktail() {
        cocktails.insert(DraftMenuCocktail(name: "", description: "", isManuallyEdited: true), at: 0)
    }

    func removeCocktail(id: UUID) {
        cocktails.removeAll { $0.id == id }
    }

    func updateCocktail(_ cocktail: DraftMenuCocktail) {
        guard let index = cocktails.firstIndex(where: { $0.id == cocktail.id }) else { return }
        cocktails[index] = cocktail
    }

    func submit() async {
        guard canSubmit else { return }
        isUploading = true
        uploadError = nil

        let cleanedCocktails = cocktails
            .map {
                var cocktail = $0
                cocktail.name = cocktail.name.trimmingCharacters(in: .whitespacesAndNewlines)
                cocktail.description = cocktail.description.trimmingCharacters(in: .whitespacesAndNewlines)
                return cocktail
            }
            .filter { !$0.name.isEmpty }

        do {
            completedMenu = try await menuService.createMenuUpload(
                barID: bar.id,
                imageData: imageData,
                ocrTexts: ocrTexts,
                cocktails: cleanedCocktails,
                seasonLabel: seasonLabel.nilIfEmpty,
                seasonMonth: seasonMonth,
                isCurrent: isCurrent,
                notes: notes.nilIfEmpty
            )
            HapticFeedback.success()
        } catch {
            uploadError = NetworkError.map(error)
            HapticFeedback.error()
        }

        isUploading = false
    }

    private func sortCocktailsForReview() {
        cocktails.sort { lhs, rhs in
            if lhs.hasLowConfidence != rhs.hasLowConfidence {
                return lhs.hasLowConfidence
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

private extension DraftMenuCocktail {
    var hasLowConfidence: Bool {
        guard let ocrConfidence else { return false }
        return ocrConfidence < 0.6 && !isManuallyEdited
    }
}
