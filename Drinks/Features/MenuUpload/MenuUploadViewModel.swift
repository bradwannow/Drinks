import Foundation
import PhotosUI
import SwiftUI

enum MenuUploadStep: Int, CaseIterable {
    case photos
    case details
    case review
}

@MainActor
final class MenuUploadViewModel: ObservableObject {
    @Published var step: MenuUploadStep = .photos
    @Published var selectedItems: [PhotosPickerItem] = []
    @Published var previewImages: [UIImage] = []
    @Published var imageData: [Data] = []
    @Published var ocrTexts: [String] = []
    @Published var cocktails: [DraftMenuCocktail] = []
    @Published var seasonLabel: String = MenuSeasonUtility.currentSeasonLabel()
    @Published var seasonMonth: Int = MenuSeasonUtility.currentMonth()
    @Published var isCurrent: Bool = true
    @Published var notes: String = ""
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

    var canAdvanceFromPhotos: Bool {
        !imageData.isEmpty && !isProcessingOCR
    }

    var canSubmit: Bool {
        !imageData.isEmpty && !isUploading
    }

    func loadSelectedPhotos() async {
        var loadedData: [Data] = []
        var loadedImages: [UIImage] = []

        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let compressed = StorageService.compressedJPEGData(from: data),
               let image = UIImage(data: compressed) {
                loadedData.append(compressed)
                loadedImages.append(image)
            }
        }

        imageData = loadedData
        previewImages = loadedImages
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
        if cocktails.isEmpty {
            cocktails = [DraftMenuCocktail(name: "", description: "")]
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
            break
        }
    }

    func goBack() {
        guard let previous = MenuUploadStep(rawValue: step.rawValue - 1) else { return }
        step = previous
    }

    func addCocktail() {
        cocktails.append(DraftMenuCocktail(name: "", description: "", isManuallyEdited: true))
    }

    func removeCocktail(id: UUID) {
        cocktails.removeAll { $0.id == id }
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
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
