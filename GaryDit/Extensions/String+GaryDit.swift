//
//  String+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 16/07/2023.
//

import Foundation

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}

extension Substring {
    
    func toString() -> String {
        return String(self)
    }
}
