//
//  Item.swift
//  SnapPuzzler
//
//  Created by ROSZHAN RAJ on 14/03/26.
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
