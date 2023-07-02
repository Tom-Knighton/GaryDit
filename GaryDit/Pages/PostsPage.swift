//
//  PostsPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation
import SwiftUI

public struct PostsPage: View {
    
    @State private var viewModel = SubredditViewModel(subredditName: "")
    
    public var body: some View {
        ZStack {
            Color.layer1.ignoresSafeArea()
            
            List {
                ForEach(self.viewModel.posts, id: \.id) { post in
                    PostView(post: post)
                        .padding(.horizontal, 12)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .task {
                            if self.viewModel.shouldFetchMore(from: post.id) {
                                await self.viewModel.fetchPosts(after: post.name)
                            }
                        }
                }
                
                if self.viewModel.isLoading {
                    HStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    
                }
                
                if self.viewModel.noMorePosts {
                    NoMorePostsView()
                        .padding(.horizontal, 12)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                
                
               
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .background(Color.layer1)
            .navigationTitle(self.viewModel.subredditName.isEmpty ? "Loading..." : self.viewModel.subredditName)
            .task {
                self.viewModel.setSubredditName(to: "GaryDitTesting", fetchPostsAutomatically: true)
            }
        }
        
    }
}
