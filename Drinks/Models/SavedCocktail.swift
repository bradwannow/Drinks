import Foundation

struct SavedCocktail: Identifiable, Codable, Hashable {
    let id: UUID
    let userID: UUID
    let cocktailID: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case cocktailID = "cocktail_id"
        case createdAt = "created_at"
    }
}

struct SavedCocktailInsert: Encodable {
    let userID: UUID
    let cocktailID: UUID

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case cocktailID = "cocktail_id"
    }
}
