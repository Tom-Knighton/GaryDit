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
    
    var comments: [PostComment]

    var body: some View {
        VStack {
            ForEach(comments, id: \.commentId) { comment in
                PostCommentView(comment: comment)
            }
        }
        .padding(.horizontal, 12)
    }
}
