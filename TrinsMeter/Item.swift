//
//  Item.swift
//  TrinsMeter
//
//  Created by Paolo Dionesalvi on 05/11/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var title: String
    var notes: String?
    
    init(timestamp: Date = Date(), title: String = "", notes: String? = nil) {
        self.timestamp = timestamp
        self.title = title
        self.notes = notes
    }
}
