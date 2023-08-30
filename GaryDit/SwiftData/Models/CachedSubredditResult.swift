//
//  CachedSubredditResult.swift
//  GaryDit
//
//  Created by Tom Knighton on 30/08/2023.
//

import Foundation
import SwiftData

@Model
public class CachedSubredditResult {
    
    init(from result: SubredditSearchResult) {
        self.subredditName = result.subredditName
        self.subredditIconImage = result.subredditImageUrl ?? ""
        self.subscribedCount = result.subredditSubscriberCount
        self.onlineCount = result.subredditActiveCount
    }
    
    @Attribute(.unique)
    var subredditName: String
    
    var subredditIconImage: String
    var subscribedCount: Int
    var onlineCount: Int
}
