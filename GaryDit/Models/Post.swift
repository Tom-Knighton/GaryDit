//
//  Post.swift
//  GaryDit
//
//  Created by Tom Knighton on 07/07/2023.
//

import Foundation

/// A structure describing a post to reddit and it's content, belonging to a particular subreddit or user
public struct Post: Codable {
    
    /// The unique Id, or name, of the post
    let postId: String
    
    /// The authour of the post's name
    let postAuthour: String
    
    /// The name of the subreddit this was posted to
    let postSubreddit: String
    
    /// The title of the post
    let postTitle: String
    
    /// The total number of upvotes - downvotes to display for a post
    let postScore: Int
    
    /// The date the post was initially created at
    let postCreatedAt: Date
    
    /// If the post has been edited, this is the date it was *last* edited at
    let postEditedAt: Date?
    
    /// Flags regarding this post, i.e. isNSFW etc...
    let postFlagDetails: PostFlags
    
    /// The actual content of this post
    let postContent: PostContent
}

extension Post: Hashable {
    public static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.postId == rhs.postId
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(postId)
    }
}
