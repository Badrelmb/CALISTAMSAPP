//
//  Item.swift
//  Calista-app
//
//  Created by Badr El malki berrada on 8/5/24.
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
