//
//  SubredditNavModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 30/08/2023.
//

import Foundation

public struct SubredditNavModel {
    let subredditName: String
    var overrideFilteredPosts: [Post]? = nil
}

public struct SubredditNavSearchQuery {
    public let subredditToSearch: String
    public let searchQuery: String
}

extension SubredditNavModel: Hashable {}
extension SubredditNavSearchQuery: Hashable {}
