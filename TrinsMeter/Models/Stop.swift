import Foundation

struct Stop: Codable, Identifiable, Hashable {
    let stop_id: Int
    let stop_name: String
    let lat: Double
    let lng: Double
    
    var id: String { String(stop_id) }
    
    // Per compatibilità con la vecchia struttura Location
    var location: Location {
        Location(latitude: lat, longitude: lng)
    }
    
    struct Location: Codable, Hashable {
        let latitude: Double
        let longitude: Double
    }
}

struct RouteStops: Codable {
    let percorso0: [Stop]
    let percorso1: [Stop]
} 