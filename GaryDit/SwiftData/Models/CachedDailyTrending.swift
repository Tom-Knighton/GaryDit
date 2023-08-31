//
//  CachedDailyTrending.swift
//  GaryDit
//
//  Created by Tom Knighton on 31/08/2023.
//

import Foundation
import SwiftData

@Model
public class CachedDailyTrendingModel {
    
    init(cacheKey: String, subreddits: [String]) {
        self.cacheKey = cacheKey
        self.subreddits = subreddits
        self.cachedAt = Date()
    }
    
    @Attribute(.unique)
    public let cacheKey: String
    
    public let cachedAt: Date
    public let subreddits: [String]
}
