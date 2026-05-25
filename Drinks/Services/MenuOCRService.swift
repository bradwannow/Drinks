import Foundation
import Vision
import UIKit

enum MenuOCRService {
    static func extractText(from imageData: Data) async throws -> String {
        guard let uiImage = UIImage(data: imageData),
              let cgImage = uiImage.cgImage else {
            return ""
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                continuation.resume(returning: lines.joined(separator: "\n"))
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    static func parseCocktails(from rawText: String) -> [DraftMenuCocktail] {
        let lines = rawText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else { return [] }

        var entries: [DraftMenuCocktail] = []
        var currentName: String?
        var descriptionLines: [String] = []
        var currentPrice: String?

        func flushEntry() {
            guard let name = currentName else { return }
            let description = descriptionLines.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            let confidence: Float = description.isEmpty ? 0.45 : 0.72
            entries.append(
                DraftMenuCocktail(
                    name: name,
                    description: description,
                    priceText: currentPrice,
                    ocrConfidence: confidence
                )
            )
            currentName = nil
            descriptionLines = []
            currentPrice = nil
        }

        for line in lines {
            if isNoiseLine(line) { continue }

            if let price = extractPrice(from: line) {
                currentPrice = price
                let withoutPrice = line.replacingOccurrences(of: price, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if withoutPrice.isEmpty { continue }
                if currentName == nil, looksLikeCocktailName(withoutPrice) {
                    flushEntry()
                    currentName = withoutPrice
                } else if currentName != nil {
                    descriptionLines.append(withoutPrice)
                }
                continue
            }

            if looksLikeCocktailName(line) {
                flushEntry()
                currentName = line
            } else if currentName != nil {
                descriptionLines.append(line)
            } else if line.count > 3 {
                currentName = line
            }
        }

        flushEntry()
        return entries
    }

    static func parseCocktails(from imageDataCollection: [Data]) async -> [DraftMenuCocktail] {
        var combinedText = ""
        for data in imageDataCollection {
            if let text = try? await extractText(from: data), !text.isEmpty {
                if !combinedText.isEmpty { combinedText += "\n\n" }
                combinedText += text
            }
        }
        return parseCocktails(from: combinedText)
    }

    private static func isNoiseLine(_ line: String) -> Bool {
        let lowered = line.lowercased()
        let noise = ["cocktails", "signature", "classics", "seasonal", "specials", "menu", "drinks"]
        if noise.contains(where: { lowered == $0 }) { return true }
        if line.count <= 2 { return true }
        return false
    }

    private static func looksLikeCocktailName(_ line: String) -> Bool {
        guard line.count >= 3, line.count <= 48 else { return false }
        if line.filter({ $0 == "." }).count > 2 { return false }
        if line.contains("  ") { return false }
        if line.first?.isNumber == true { return false }
        let wordCount = line.split(separator: " ").count
        return wordCount <= 6
    }

    private static func extractPrice(from line: String) -> String? {
        let pattern = #"\$?\d{1,3}(?:\.\d{2})?"#
        guard let range = line.range(of: pattern, options: .regularExpression) else { return nil }
        return String(line[range])
    }
}
