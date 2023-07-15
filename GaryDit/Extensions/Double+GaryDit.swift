//
//  Double+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 19/06/2023.
//

import Foundation

extension Double {
    func reduceScale(to places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
    
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .pad
        var formatted = formatter.string(from: self) ?? ""
        if formatted.starts(with: "00:") {
            formatted = String(formatted.dropFirst(3))
        }
        
        return formatted
      }
}
