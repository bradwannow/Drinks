import Foundation

struct BarRoute: Hashable {
    let id: UUID
}

struct MenuVersionRoute: Hashable {
    let id: UUID
    var previousVersionID: UUID?
}
