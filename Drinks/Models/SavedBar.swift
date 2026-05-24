import Foundation

struct SavedBar: Identifiable, Codable, Hashable {
    let id: UUID
    let userID: UUID
    let barID: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case barID = "bar_id"
        case createdAt = "created_at"
    }
}

struct SavedBarInsert: Encodable {
    let userID: UUID
    let barID: UUID

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case barID = "bar_id"
    }
}
