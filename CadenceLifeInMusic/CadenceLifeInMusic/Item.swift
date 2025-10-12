//
//  Item.swift
//  CadenceLifeInMusic
//
//  Created by Aylin ULABA on 13.10.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
