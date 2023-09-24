//
//  Sort.swift
//  GaryDit
//
//  Created by Tom Knighton on 23/09/2023.
//

import Foundation

public enum RedditSort: String, Codable {
    
    case hot = "hot"
    case new = "new"
    case top = "top"
    case topToday = "topDaily"
    case topWeek = "topWeekly"
    case topMonth = "topMonthly"
    case topYear = "topYearly"
    case topAll = "topAll"
    case controversial = "controversial"
    case controversialToday = "controversialDaily"
    case controversialWeek = "controversialWeekly"
    case controversialMonth = "controversialMonthly"
    case controversialYear = "controversialYearly"
    case controversialAll = "controversialAll"
    case rising = "rising"
    
    case best = "best"
    case qa = "q_and_a"
    
    public static let topOptions: [RedditSort] = [.top, .topToday, .topWeek, .topMonth, .topYear, .topAll]
    public static let controversialOptions: [RedditSort] = [.controversial, .controversialToday, .controversialWeek, .controversialMonth, .controversialYear, .controversialAll]
}

public extension RedditSort {
    
    static func iconName(_ sort: RedditSort) -> String {
        switch sort {
        case .hot:
            return "flame"
        case .rising:
            return "chart.line.uptrend.xyaxis"
        case .new:
            return "clock"
        case .best:
            return "trophy"
        case .qa:
            return "mic"
        default:
            if RedditSort.topOptions.contains(sort) {
                return "arrow.up.to.line"
            }
            
            if RedditSort.controversialOptions.contains(sort) {
                return "cloud.bolt"
            }
            
            return "questionmark"
        }
    }
}
