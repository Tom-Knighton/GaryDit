//
//  SearchHistory.swift
//  GaryDit
//
//  Created by Tom Knighton on 31/08/2023.
//

import Foundation
import SwiftData

@Model
public class SearchHistoryModel {
    
    init(from subreddit: SubredditSearchResult) {
        self.name = subreddit.subredditName
        self.imageUrl = subreddit.subredditImageUrl ?? ""
        self.type = .subreddit
        self.accessedAt = Date()
    }
    
    init(from user: UserSearchResult) {
        self.name = "u/" + user.username
        self.imageUrl = user.userProfileImage ?? ""
        self.type = .user
        self.accessedAt = Date()
    }
    
    init (from trendName: String) {
        self.name = trendName
        self.imageUrl = ""
        self.type = .trendSubreddit
        self.accessedAt = Date()
    }
    
    @Attribute(.unique)
    var name: String
    var imageUrl: String

    var type: SearchHistoryType = SearchHistoryType.subreddit
    
    var accessedAt: Date
}

public enum SearchHistoryType: Int, Codable {
    case user = 0
    case subreddit = 1
    case trendSubreddit = 2
}
