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
            topMediaView()
            
            VStack {
                Text(viewModel.post.postTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let text = viewModel.post.postContent.textContent, text.isEmpty == false {
                    Text(text)
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
    
    @ViewBuilder
    func topMediaView() -> some View {
        let content = self.viewModel.post.postContent
        let media = content.media
        if media.isEmpty {
            EmptyView()
        } else {
            if media.count > 1 {
                EmptyView()
            } else if let first = media.first {
                switch content.contentType {
                case .image:
                    if first.url.contains(".gif") {
                        gifView(first.url, aspectRatio: first.width / first.height)
                    } else {
                        imageView(first.url)
                    }
                case .video:
                    videoView(first.url, aspectRatio: first.width / first.height)
                case .linkOnly:
                    linkView(first.url, thumbnailUrl: first.thumbnailUrl)
                default:
                    EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    func gifView(_ url: String, aspectRatio: Double = 1) -> some View {
        VStack {
            GIFImage(url)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .onAppear {
                    self.isPlayingMedia = true
                }
                .onDisappear {
                    self.isPlayingMedia = false
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func videoView(_ url: String, aspectRatio: Double = 1) -> some View {
        VStack{
            PlayerView(url: url, isPlaying: $isPlayingMedia)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .onAppear {
                    self.isPlayingMedia = true
                }
                .onDisappear {
                    self.isPlayingMedia = false
                }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func imageView(_ url: String) -> some View {
        AsyncImage(url: URL(string: url), content: { image in
            image.resizable()
                .aspectRatio(contentMode: .fit)
        }, placeholder: {
            RoundedRectangle(cornerRadius: 10)
                .redacted(reason: .placeholder)
        })
    }
    
    @ViewBuilder
    func linkView(_ url: String, thumbnailUrl: String? = nil) -> some View {
        LinkView(url: url, overrideImage: thumbnailUrl ?? "", fetchMetadata: false)
            .padding(.horizontal, 8)
    }
}
