//
//  PostPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 28/07/2023.
//

import Foundation
import SwiftUI

struct PostPage: View {
    
    @State private var viewModel: RedditPostViewModel
    
    init(post: Post) {
        _viewModel = State(wrappedValue: RedditPostViewModel(post: post))
    }
    
    init(postViewModel: RedditPostViewModel) {
        _viewModel = State(wrappedValue: postViewModel)
    }
    
    var body: some View {
        
        ZStack {
            Color.layer1.ignoresSafeArea()
            ScrollView {
                VStack {
                    PostViewPostDetails(viewModel: viewModel)
                    if self.viewModel.isLoadingComments {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    PostCommentListView()
                    Spacer()
                }
            }
        }
        .environment(viewModel)
        .navigationTitle(Text("^[\(viewModel.post.postCommentCount) Comment](inflect: true)"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if self.viewModel.comments.isEmpty {
                await self.viewModel.loadComments()
            }
        }
    }
}
