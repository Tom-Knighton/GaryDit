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
    let postAuthor: String
    
    /// The OP's flair text, if any
    let postAuthorFlair: String?
    
    /// The name of the subreddit this was posted to
    let postSubreddit: String
    
    /// The title of the post
    let postTitle: String
    
    /// The total number of upvotes - downvotes to display for a post
    let postScore: Int
    
    /// The ratio of upvotes to downvotes - as a percentage
    let postScorePercentage: Int
    
    /// The date the post was initially created at
    let postCreatedAt: Date
    
    /// If the post has been edited, this is the date it was *last* edited at
    let postEditedAt: Date?
    
    /// The number of comments on this post
    let postCommentCount: Int
    
    /// The icon of the subreddit the post was posted to
    let subredditIcon: String?
    
    /// Flags regarding this post, i.e. isNSFW etc...
    var postFlagDetails: PostFlags
    
    /// The actual content of this post
    let postContent: PostContent
    
    /// How the user has voted, if at all, on this post
    var postVoteStatus: VoteStatus
    
    /// The post's flair, if any, as markdown text
    let postFlair: String?
}

extension Post: Hashable {
    public static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.postId == rhs.postId && lhs.postVoteStatus == rhs.postVoteStatus && lhs.postFlagDetails.isSaved == rhs.postFlagDetails.isSaved
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(postId)
        hasher.combine(postVoteStatus)
        hasher.combine(postFlagDetails)
    }
}

public enum VoteStatus: String, Codable {
    case upvoted = "upvoted"
    case downvoted = "downvoted"
    case noVote = "noVote"
    
    func opposite() -> VoteStatus {
        switch self {
        case .upvoted:
            return .downvoted
        case .downvoted:
            return .upvoted
        case .noVote:
            return .noVote
        }
    }
}
