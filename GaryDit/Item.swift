//
//  Item.swift
//  GaryDit
//
//  Created by Tom Knighton on 16/06/2023.
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
