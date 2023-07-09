//
//  PostView.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation
import SwiftUI
import VideoPlayer

struct PostView: View {
    
    @ObservedObject private var viewModel: RedditPostViewModel
    @State private var togglePreview: Bool = false
    @State private var isPlayingMedia: Bool = false
    
    init(post: Post) {
        self.viewModel = RedditPostViewModel(post: post)
    }
    
    var body: some View {
        VStack {
            PostTopMediaView(content: viewModel.post.postContent)
            
            VStack {
                Text(viewModel.post.postTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, viewModel.post.postContent.media.isEmpty ? 8 : 0)
                
                if let text = viewModel.post.postContent.textContent, text.isEmpty == false {
                    Text(text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(5)
                        .padding(.vertical, 0)
                        .foregroundStyle(.gray)
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 8)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.post.postSubreddit)
                        .font(.subheadline)
                        .bold()
                    HStack {
                        HStack(spacing: 2) {
                            Text(Image(systemName: "arrow.up"))
                            Text(viewModel.post.postScore.friendlyFormat())
                        }
                        HStack(spacing: 2) {
                            Text(Image(systemName: "message"))
                            Text(viewModel.post.postScore.friendlyFormat()) //TODO
                        }
                        HStack(spacing: 2) {
                            Text(Image(systemName: "clock"))
                            Text(viewModel.post.postCreatedAt.friendlyAgo)
                        }
                    }
                    .font(.subheadline)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            
        }
        .padding(.bottom, 8)
        .background(Color.layer2)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.vertical, 4)
        .shadow(radius: 3)
    }
    
    
}
