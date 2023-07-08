//
//  Date+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 07/07/2023.
//

import Foundation

extension Date {
    
    var friendlyAgo: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
    }
}
