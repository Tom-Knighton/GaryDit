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
    
    init(post: RedditPost) {
        self.viewModel = RedditPostViewModel(post: post)
    }
    
    var body: some View {
        VStack {
            if let media = viewModel.post.extractMedia() {
                if media.isVideo {
                    if media.urlString.contains(".gif") {
                        gifView()
                    } else {
                        videoView()
                    }
                } else if viewModel.getPostType() == .Image {
                    imageView()
                } else if viewModel.getPostType() == .Link {
                    LinkView(url: viewModel.post.extractMedia()?.urlString ?? "", overrideImage: viewModel.post.thumbnail, fetchMetadata: false)
                        .padding(.horizontal, 8)
                }
            }
            
            VStack {
                Text(viewModel.post.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if viewModel.post.getPostType() == .SelfPost && viewModel.post.selftext.isEmpty == false {
                    Text(viewModel.post.selftext)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(5)
                        .padding(.vertical, 0)
                        .foregroundStyle(.gray)
                        .opacity(0.8)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 8)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.post.subreddit)
                        .font(.subheadline)
                        .bold()
                    HStack {
                        HStack(spacing: 2) {
                            Text(Image(systemName: "arrow.up"))
                            Text(viewModel.post.score.friendlyFormat())
                        }
                        HStack(spacing: 2) {
                            Text(Image(systemName: "message"))
                            Text(viewModel.post.numComments.friendlyFormat())
                        }
                        HStack(spacing: 2) {
                            Text(Image(systemName: "clock"))
                            Text(viewModel.post.friendlyCreatedAgo)
                        }
                    }
                    .font(.subheadline)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            
        }
        .padding(.bottom, 8)
        .background(Color.layer1)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.vertical, 4)
        .shadow(radius: 3)
    }
    
    @ViewBuilder
    func gifView() -> some View {
        if let media = self.viewModel.post.extractMedia() {
            VStack {
                GIFView(url: viewModel.post.url ?? "", isPlaying: $isPlayingMedia)
                    .aspectRatio(media.aspectRatio, contentMode: .fit)
                    .onAppear {
                        self.isPlayingMedia = true
                    }
                    .onDisappear {
                        self.isPlayingMedia = false
                    }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    func videoView() -> some View {
        if let media = self.viewModel.post.extractMedia() {
            VStack{
                PlayerView(url: media.urlString, isPlaying: $isPlayingMedia)
                    .aspectRatio(media.aspectRatio, contentMode: .fit)
                    .onAppear {
                        self.isPlayingMedia = true
                    }
                    .onDisappear {
                        self.isPlayingMedia = false
                    }
            }
            .frame(maxWidth: .infinity)
        } else {
            EmptyView()
                .frame(width: 0, height: 0)
        }
    }
    
    @ViewBuilder
    func imageView() -> some View {
        if let media = self.viewModel.post.extractMedia() {
            AsyncImage(url: URL(string: media.urlString), content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            }, placeholder: {
                RoundedRectangle(cornerRadius: 10)
                    .redacted(reason: .placeholder)
            })
        } else {
            EmptyView() //TODO:
        }
    }
}
