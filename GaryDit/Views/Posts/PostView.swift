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
    
    @Environment(SubredditViewModel.self) private var subreddit
    @State private var viewModel: RedditPostViewModel
    @State private var togglePreview: Bool = false
    @State private var isPlayingMedia: Bool = false
    
    @State private var presentMedia: Bool = false
            
    init(post: Post) {
        self._viewModel = State(initialValue: RedditPostViewModel(post: post))
    }
    
    var body: some View {
        VStack {
            PostTopMediaView(content: viewModel.post.postContent)
                .onTapGesture {
                    self.presentMedia = true
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.post.postTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, viewModel.post.postContent.media.isEmpty ? 8 : 0)
                
                if viewModel.post.postFlagDetails.isNSFW {
                    Text("NSFW")
                        .font(.caption2)
                        .padding(4)
                        .background(.red)
                        .clipShape(.rect(cornerRadius: 5))
                }
                
                if let text = viewModel.post.postContent.textContent, text.isEmpty == false {
                    Text(text)
                        .lineLimit(5)
                        .padding(.vertical, 0)
                        .foregroundStyle(.gray)
                        .opacity(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 8)
            
            HStack {
                VStack(alignment: .leading) {
                    HStack(spacing: 2) {
                        bylineText()
                        if viewModel.post.postFlagDetails.isStickied {
                            Text(Image(systemName: "pin.fill"))
                                .foregroundStyle(.green)
                        }
                        if viewModel.post.postFlagDetails.isLocked {
                            Text(Image(systemName: "lock.fill"))
                                .foregroundStyle(.yellow)
                        }
                        if viewModel.post.postFlagDetails.isArchived {
                            Text(Image(systemName: "archivebox.fill"))
                                .foregroundStyle(.yellow)
                        }
                    }
                    .bold()
                    .font(.subheadline)
                    .foregroundStyle(bylineColour)

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
        .fullScreenCover(isPresented: $presentMedia, content: {
            MediaGalleryView()
                .environment(viewModel)
                .background(BackgroundCleanerView())
        })
      
    }
    
    @ViewBuilder
    func bylineText() -> some View {
        switch self.subreddit.bylineDisplayBehaviour {
        case .showSubreddit:
            Text(viewModel.post.postSubreddit)
        case .showUsername:
            Text("By \(viewModel.post.postAuthour)")
        }
    }
    
    var bylineColour: Color {
        switch self.viewModel.post.postFlagDetails.distinguishmentType {
        case .none:
            return .primary
        case .moderator:
            return .green
        case .admin:
            return .red
        case .special:
            return .darkRed
        }
    }
}
