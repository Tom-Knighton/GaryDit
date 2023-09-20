//
//  CommentViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 19/09/2023.
//

import SwiftUI
import Observation

@Observable
class CommentViewModel {
    
    var comment: PostComment
    var replies: [PostComment]
    var voteStatus: VoteStatus

    var isCollapsed: Bool = false
    
    var isBookmarked: Bool = false
    
    init(comment: PostComment) {
        self.comment = comment
        self.replies = comment.replies
        self.voteStatus = comment.voteStatus
        self.isBookmarked = comment.commentFlagDetails.isSaved
    }
    
    public func voteOnComment(_ commentId: String, status: VoteStatus) {
        guard let index = replies.firstIndex(where: { $0.commentId == commentId }) else {
            return
        }
        
        self.replies[index].voteStatus = status
    }
}
