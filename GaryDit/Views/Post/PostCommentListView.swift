//
//  PostCommentsView.swift
//  GaryDit
//
//  Created by Tom Knighton on 30/07/2023.
//

import Foundation
import SwiftUI

struct PostCommentListView: View {
    
    @Environment(RedditPostViewModel.self) private var viewModel
    
    var body: some View {
        SwipeViewGroup {
            LazyVStack {
                ForEach(viewModel.comments, id: \.commentId) { comment in
                    PostCommentView(comment: comment, postId: viewModel.post.postId, postAuthor: viewModel.post.postAuthor, nestLevel: 0, onCommentLiked: { commentId, newStatus in
                        self.viewModel.voteOnComment(commentId, status: newStatus)
                    }, onCommentSaved: { commentId, saved in
                        self.viewModel.toggleSave(commentId, status: saved)
                    })
                }
            }
            .padding(.horizontal, 12)
        }
    }
}
