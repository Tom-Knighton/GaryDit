//
//  PostComment.swift
//  GaryDit
//
//  Created by Tom Knighton on 04/08/2023.
//

import Foundation
import SwiftUI

public struct PostComment: Codable {
    
    /// The unique id of the comment
    public let commentId: String
    
    /// The user who posted this comment
    public let commentAuthour: String
    
    /// The score for this comment, upvotes - downvotes
    public let commentScore: Int
    
    /// The acutal text body of this comment
    public let commentText: String
    
    /// The time this comment was created in UTC
    public let commentCreatedAt: Date
    
    /// If edited, the time this comment was last edited
    public let commentEditedAt: Date?
    
    /// How the user has voted, if at all, on this comment
    public let voteStatus: VoteStatus
    
    /// Flags about this comment, including sticky status, distinguishment etc.
    public let commentFlagDetails: PostFlags
    
    /// Any replies to this comment
    public var replies: [PostComment]
    
    /// If present, the comment is a 'Load more' link that represents comment ids to be loaded as children to this object's parent
    public let loadMoreLink: LoadMoreLink?
    
    // Inline media, if any, of the post
    public var media: [PostMedia]
    
    func getMarkdownText() -> LocalizedStringKey {
        return LocalizedStringKey(self.commentText)
    }
}

extension PostComment: Hashable, Equatable {
    public static func == (lhs: PostComment, rhs: PostComment) -> Bool {
        return lhs.commentId == rhs.commentId && lhs.replies == rhs.replies && lhs.replies.count == rhs.replies.count && lhs.commentText == rhs.commentText
    }
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(commentId)
        hasher.combine(replies.count)
        hasher.combine(replies)
        hasher.combine(commentText)
    }
}

/// A structure representing a link to load more comments, and the ids that should then be loaded
public struct LoadMoreLink: Codable {
    /// The number of actual child comments to load, including children to depth 0 objects
    public let moreCount: Int
    
    /// The root or depth 0 ids to load
    public let moreChildren: [String]
    
    /// Whether or not the link is a 'Continue Thread' link, which should be dealth with accordingly
    public let isContinueThreadLink: Bool
}

public struct MoreCommentsDto: Codable {
    /// The comment id to replace
    let moreLinkId: String
    
    /// The comments to add to the tree
    let comments: [PostComment]
}
