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
        self.isUser = false
        self.accessedAt = Date()
    }
    
    init(from user: UserSearchResult) {
        self.name = "u/" + user.username
        self.imageUrl = user.userProfileImage ?? ""
        self.isUser = true
        self.accessedAt = Date()
    }
    
    @Attribute(.unique)
    var name: String
    var imageUrl: String
    var isUser: Bool
    
    var accessedAt: Date
}
