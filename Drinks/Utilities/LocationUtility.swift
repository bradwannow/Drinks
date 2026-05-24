import CoreLocation
import Foundation

struct Coordinate: Hashable {
    let latitude: Double
    let longitude: Double

    static let defaultReference = Coordinate(latitude: 41.8781, longitude: -87.6298)
}

enum LocationUtility {
    static func distanceMiles(from origin: Coordinate, to destination: Coordinate) -> Double {
        let originLocation = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let meters = originLocation.distance(from: destinationLocation)
        return meters / 1609.344
    }
}
