//
//  PostFlags.swift
//  GaryDit
//
//  Created by Tom Knighton on 07/07/2023.
//

import Foundation

/// Flags about a specific post
public struct PostFlags: Codable {
    
    /// Whether or not the content is marked as NSFW
    let isNSFW: Bool
    
    /// Whether or not the content has been saved by the current user
    var isSaved: Bool
    
    /// Whether or not the content has been locked by admins, and no more changes are allowed
    let isLocked: Bool
    
    /// Whether or not the content has been stickied to the top of it's parent
    let isStickied: Bool
    
    /// Whether or not the content has been archived by it's subreddit, and no more changes are allowed
    let isArchived: Bool
    
    /// Whether or not the content is marked as a spoiler, and should be hidden or blurred
    let isSpoiler: Bool
    
    /// Whether or not the content is distinguished, and how so
    let distinguishmentType: DistinguishmentType
}

extension PostFlags: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(isSaved)
    }
}
