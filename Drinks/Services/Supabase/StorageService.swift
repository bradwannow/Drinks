import Foundation
import Supabase
import UIKit

final class StorageService {
    static let shared = StorageService()

    private enum Bucket {
        static let menuImages = "menu-images"
    }

    private let manager: SupabaseManager

    init(manager: SupabaseManager = .shared) {
        self.manager = manager
    }

    func uploadMenuImage(
        data: Data,
        barID: UUID,
        menuVersionID: UUID,
        sortOrder: Int
    ) async throws -> (path: String, publicURL: URL) {
        let client = try manager.requireClient()
        let contentType = Self.detectContentType(for: data)
        let fileExtension = Self.fileExtension(for: contentType)
        let fileName = "\(UUID().uuidString).\(fileExtension)"
        let path = "\(barID.uuidString)/\(menuVersionID.uuidString)/\(fileName)"

        try await client.storage
            .from(Bucket.menuImages)
            .upload(
                path,
                data: data,
                options: FileOptions(contentType: contentType, upsert: false)
            )

        let publicURL = try client.storage
            .from(Bucket.menuImages)
            .getPublicURL(path: path)

        return (path, publicURL)
    }

    func publicURL(forStoragePath path: String) throws -> URL {
        let client = try manager.requireClient()
        return try client.storage
            .from(Bucket.menuImages)
            .getPublicURL(path: path)
    }

    private static func detectContentType(for data: Data) -> String {
        if data.starts(with: [0xFF, 0xD8, 0xFF]) { return "image/jpeg" }
        if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) { return "image/png" }
        if data.starts(with: [0x52, 0x49, 0x46, 0x46]) { return "image/webp" }
        return "image/jpeg"
    }

    private static func fileExtension(for contentType: String) -> String {
        switch contentType {
        case "image/png": return "png"
        case "image/webp": return "webp"
        default: return "jpg"
        }
    }

    static func compressedJPEGData(from data: Data, maxDimension: CGFloat = 2048) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let maxSide = max(size.width, size.height)
        let scale = min(1, maxDimension / maxSide)
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resized.jpegData(compressionQuality: 0.82) ?? data
    }
}
