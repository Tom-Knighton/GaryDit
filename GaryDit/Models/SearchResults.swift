//
//  SearchResults.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/08/2023.
//

import Foundation

public struct SubredditSearchResult: Codable {
    public let subredditImageUrl: String?
    public let subredditName: String
    public let subredditSubscriberCount: Int
    public let subredditActiveCount: Int
}

public struct UserSearchResult: Codable {
    public let username: String
    public let userProfileImage: String?
    public let isEmployee: Bool
    public let isVerified: Bool
    public let isNsfw: Bool
    public let isFriend: Bool
}


extension SubredditSearchResult {
    
    init(from cached: CachedSubredditResult) {
        self.init(subredditImageUrl: cached.subredditIconImage, subredditName: cached.subredditName, subredditSubscriberCount: cached.subscribedCount, subredditActiveCount: cached.onlineCount)
    }
}
