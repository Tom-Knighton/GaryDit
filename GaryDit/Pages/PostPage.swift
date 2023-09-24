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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { self.viewModel.changeSortMethod(to: .best) }) { Text("Best"); Image(systemName: RedditSort.iconName(.best)) }
                    Button(action: { self.viewModel.changeSortMethod(to: .new) }) { Text("New"); Image(systemName: RedditSort.iconName(.new)) }
                    Button(action: { self.viewModel.changeSortMethod(to: .top) }) { Text("Top"); Image(systemName: RedditSort.iconName(.top)) }
                    Button(action: { self.viewModel.changeSortMethod(to: .qa) }) { Text("Q&A"); Image(systemName: RedditSort.iconName(.qa)) }
                    Button(action: { self.viewModel.changeSortMethod(to: .controversial) }) { Text("Controversial"); Image(systemName: RedditSort.iconName(.controversial)) }
                } label: {
                    Image(systemName: RedditSort.iconName(self.viewModel.sortMethod))
                }
            }
        }
        .task {
            if !self.viewModel.hasLoadedCommentsBefore {
                await self.viewModel.loadComments()
            }
        }
    }
}
