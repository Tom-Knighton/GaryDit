//
//  Collection+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 14/07/2023.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
