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
        var ago = String(format: formatter.string(from: self, to: Date()) ?? "", locale: .current)
        
        let letters = ago.filter({$0.isLetter})
        if letters.count == 1 && letters == "s" {
            ago = "Now"
        }
        
        return ago
    }
}
