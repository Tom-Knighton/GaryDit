//
//  PostCommentsView.swift
//  GaryDit
//
//  Created by Tom Knighton on 30/07/2023.
//

import Foundation
import SwiftUI
import MarkdownView

struct PostCommentListView: View {
    
    @Environment(RedditPostViewModel.self) private var viewModel
    
    var body: some View {
        LazyVStack {
            ForEach(viewModel.comments, id: \.commentId) { comment in
                PostCommentView(comment: comment, postId: viewModel.post.postId, postAuthour: viewModel.post.postAuthour)
            }
        }
        .padding(.horizontal, 12)
    }
}
