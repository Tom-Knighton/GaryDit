//
//  PostsPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation
import SwiftUI

public struct PostsPage: View {
    
    @State var subredditName: String = "All"
    @State private var posts: [RedditPost] = []
    
    public var body: some View {
        ZStack {
            Color.layer1.ignoresSafeArea()
            
            ScrollView {
                LazyVStack {
                    ForEach(posts, id: \.title) { post in
                        PostView(post: post)
                            .padding(.horizontal, 12)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
               
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .background(Color.layer1)
            .navigationTitle(subredditName)
            .task {
                self.posts = (try? await SubredditService.GetPosts(for: subredditName)) ?? []
            }
        }
        
    }
}
