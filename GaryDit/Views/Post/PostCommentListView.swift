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
    
    @Bindable var viewModel: RedditPostViewModel
    
    
    
    var body: some View {
        VStack {
            ForEach(self.$viewModel.comments, id: \.commentId) { $comment in
                PostCommentView(comment: $comment)
            }
        }
        .task {
            print("here")
            await self.viewModel.loadComments()
        }
        .onChange(of: self.viewModel.comments, initial: true) { oldValue, newValue in
            print("comments changed: \(newValue.count)")
        }
    }
}
