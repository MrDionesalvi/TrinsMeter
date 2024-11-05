import Foundation
import SwiftData

@Model
final class TransitLine {
    var id: String
    var name: String
    var type: TransitType
    var color: String
    var isFavorite: Bool
    var lastUsed: Date?
    var defaultStartStopId: Int?
    var defaultEndStopId: Int?
    var direction: Int?
    
    var trips: Int {
        tripHistory.count
    }
    
    @Relationship(deleteRule: .cascade) var tripHistory: [Trip] = []
    
    init(id: String = UUID().uuidString,
         name: String,
         type: TransitType,
         color: String = "#007AFF",
         isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.type = type
        self.color = color
        self.isFavorite = isFavorite
    }
}

enum TransitType: String, Codable {
    case metro = "METRO"
    case tram = "TRAM"
    case bus = "BUS"
    
    var icon: String {
        switch self {
        case .metro: return "tram.fill.tunnel"
        case .tram: return "tram.fill"
        case .bus: return "bus.fill"
        }
    }
} 
