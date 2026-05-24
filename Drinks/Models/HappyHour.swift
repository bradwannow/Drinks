import Foundation

struct HappyHour: Identifiable, Hashable {
    let id: UUID
    let barName: String
    let barImageURL: URL
    let neighborhood: String
    let timeRange: String
    let dealDescription: String
    let daysActive: String

    init(
        id: UUID = UUID(),
        barName: String,
        barImageURL: URL,
        neighborhood: String,
        timeRange: String,
        dealDescription: String,
        daysActive: String
    ) {
        self.id = id
        self.barName = barName
        self.barImageURL = barImageURL
        self.neighborhood = neighborhood
        self.timeRange = timeRange
        self.dealDescription = dealDescription
        self.daysActive = daysActive
    }
}
