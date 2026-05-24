import Foundation

struct HappyHour: Identifiable, Hashable, Codable {
    let id: UUID
    let barID: UUID
    let barName: String
    let barImageURL: URL
    let neighborhood: String
    let timeRange: String
    let dealDescription: String
    let daysActive: String

    init(
        id: UUID = UUID(),
        barID: UUID = UUID(),
        barName: String,
        barImageURL: URL,
        neighborhood: String,
        timeRange: String,
        dealDescription: String,
        daysActive: String
    ) {
        self.id = id
        self.barID = barID
        self.barName = barName
        self.barImageURL = barImageURL
        self.neighborhood = neighborhood
        self.timeRange = timeRange
        self.dealDescription = dealDescription
        self.daysActive = daysActive
    }

    enum CodingKeys: String, CodingKey {
        case id
        case barID = "bar_id"
        case barName = "bar_name"
        case barImageURL = "bar_image_url"
        case neighborhood
        case timeRange = "time_range"
        case dealDescription = "deal_description"
        case daysActive = "days_active"
    }
}
