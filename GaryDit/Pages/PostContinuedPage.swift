//
//  PostContinuedPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 12/08/2023.
//

import Foundation
import SwiftUI

public struct PostContinuedPage: View {
    
    var viewModel: PostContinuedViewModel
    @State private var postModel: RedditPostViewModel
    
    init(viewModel: PostContinuedViewModel) {
        self.viewModel = viewModel
        self._postModel = State(wrappedValue: RedditPostViewModel(post: viewModel.post))
    }
    
    public var body: some View {
        ZStack {
            Color.layer1.ignoresSafeArea(.all)
            ScrollView {
                VStack {
                    ShowWholePostRow()
                        .padding(.horizontal, 12)
                    Divider()
                    PostCommentListView()
                        .environment(postModel)
                }
            }
        }
        .task {
            await self.postModel.loadComments(fromRoot: viewModel.rootCommentId)
        }
        
    }
}
