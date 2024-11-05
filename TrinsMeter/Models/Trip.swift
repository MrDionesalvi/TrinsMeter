import Foundation
import SwiftData

@Model
final class Trip {
    var id: String
    var line: TransitLine
    var startStop: Int
    var endStop: Int
    var date: Date
    var distance: Double // in km
    var co2Saved: Double // in kg
    
    init(id: String = UUID().uuidString,
         line: TransitLine,
         startStop: Int,
         endStop: Int,
         date: Date = Date(),
         distance: Double,
         co2Saved: Double) {
        self.id = id
        self.line = line
        self.startStop = startStop
        self.endStop = endStop
        self.date = date
        self.distance = distance
        self.co2Saved = co2Saved
    }
} 