import Foundation

struct Profile: Identifiable, Codable, Hashable {
    let id: UUID
    let username: String?
    let displayName: String?
    let avatarURL: URL?
    let createdAt: Date
    let updatedAt: Date

    var initials: String {
        let source = displayName ?? username ?? "?"
        let parts = source.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(source.prefix(2)).uppercased()
    }

    var handle: String? {
        guard let username, !username.isEmpty else { return nil }
        return "@\(username)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ProfileUpdate: Encodable {
    let displayName: String?
    let username: String?
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case username
        case avatarURL = "avatar_url"
    }
}
