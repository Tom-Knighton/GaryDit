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
        VStack {
            ForEach(viewModel.comments, id: \.commentId) { comment in
                PostCommentView(comment: comment)
            }
        }
        .padding(.horizontal, 12)
    }
}
