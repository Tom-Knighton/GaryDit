//
//  PostView.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation
import SwiftUI
import VideoPlayer
import RedditMarkdownView

struct ListPostView: View {
    
    @Environment(GlobalStoreViewModel.self) private var globalVM
    @Environment(SubredditViewModel.self) private var subreddit
    @State private var viewModel: RedditPostViewModel
    @State private var togglePreview: Bool = false
    @State private var isPlayingMedia: Bool = false
    
    @State private var presentMediaUrl: String? = nil
            
    init(post: Post) {
        self._viewModel = State(initialValue: RedditPostViewModel(post: post))
    }
    
    var body: some View {
        SwipeView {
            VStack {
                PostTopMediaView(showMediaUrl: $presentMediaUrl, content: viewModel.post.postContent, isSpoiler: viewModel.post.postFlagDetails.isSpoiler)
                    .environment(viewModel)
                
                VStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.post.postTitle)
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, viewModel.post.postContent.media.isEmpty ? 8 : 0)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if let flair = viewModel.post.postFlair {
                            FlairView(flairText: flair)
                        }
                        
                        HStack {
                            if viewModel.post.postFlagDetails.isNSFW {
                                Text("NSFW")
                                    .font(.caption2)
                                    .padding(4)
                                    .background(.red)
                                    .clipShape(.rect(cornerRadius: 5))
                            }
                            if viewModel.post.postFlagDetails.isSpoiler {
                                Text("SPOILER")
                                    .font(.caption2)
                                    .padding(4)
                                    .background(.gray)
                                    .clipShape(.rect(cornerRadius: 5))
                            }
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
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    
                    PostActionsView(post: self.$viewModel.post)

                }
                .accessibilityRespondsToUserInteraction()
                .contentShape(Rectangle())
                .onTapGesture {
                    self.globalVM.addToCurrentNavStack(viewModel)
                }
            }
            .padding(.bottom, 16)
            .background(Color.layer2)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.vertical, 4)
            .shadow(radius: 3)
            .fullScreenCover(item: $presentMediaUrl, content: { index in
                MediaGalleryView(selectedMediaUrl: index)
                    .environment(viewModel)
                    .background(BackgroundCleanerView())
            })
            .onChange(of: self.presentMediaUrl, initial: true) {
                if let media = self.presentMediaUrl, media.isEmpty == false {
                    NotificationCenter.default.post(name: .MediaGalleryFullscreenPresented, object: nil, userInfo: ["except": self.presentMediaUrl ?? ""])
                } else {
                    NotificationCenter.default.post(name: .MediaGalleryFullscreenDismissed, object: nil, userInfo: [:])
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .ObjectVotedOn)) { data in
                if let id = data.userInfo?["objectId"] as? String, let voteStatus = data.userInfo?["voteStatus"] as? VoteStatus {
                    if viewModel.post.postId == id {
                        withAnimation(.spring) {
                            viewModel.post.postVoteStatus = voteStatus
                        }
                    }
                }
            }
        } leadingActions: { context in
            let isSecond = context.currentDragDistance > 250
            SwipeAction(systemImage: isSecond ? (viewModel.post.postFlagDetails.isSaved ? "bookmark.slash.fill" : "bookmark.fill") : "arrow.down", backgroundColor: isSecond ? .green : .purple, action: { [context] in
                if isSecond {
                    viewModel.toggleSave()
                } else {
                    viewModel.vote(.downvoted)
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 1, blendDuration: 1)) {
                    context.state.wrappedValue = .closed
                }
            })
            .allowSwipeToTrigger()
            .onChange(of: isSecond) { _, _ in
                HapticService.start(.soft)
            }
        } trailingActions: { context in
            let isSecond = context.currentDragDistance > 250
            SwipeAction(systemImage: isSecond ? "arrowshape.turn.up.left.fill" : "arrow.up", backgroundColor: isSecond ? .blue : .orange, action: {
                if isSecond {
                    // Reply
                    
                } else {
                    viewModel.vote(.upvoted)
                }
                withAnimation(.spring(response: 0.4, dampingFraction: 1, blendDuration: 1)) {
                    context.state.wrappedValue = .closed
                }
            })
            .allowSwipeToTrigger()
            .onChange(of: isSecond) { _, _ in
                HapticService.start(.soft)
            }
        }
        .swipeActionsStyle(.cascade)
        .swipeMinimumDistance(30)
        .swipeActionCornerRadius(10)
        .allowSwipeToTrigger()
    }
    
    @ViewBuilder
    func bylineText() -> some View {
        switch self.subreddit.bylineDisplayBehaviour {
        case .showSubreddit:
            HStack(spacing: 4) {
                if let url = URL(string: viewModel.post.subredditIcon ?? "") {
                    CachedImageView(url: url.absoluteString)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .clipShape(.circle)
                        .shadow(radius: 3)
                }
                Text(viewModel.post.postSubreddit)

            }
        case .showUsername:
            HStack(spacing: 2) {
                Text("By \(viewModel.post.postAuthor)")
                if let flair = viewModel.post.postAuthorFlair, flair.isEmpty == false {
                    FlairView(flairText: flair)
                        .lineLimit(1)
                        .frame(maxWidth: 200)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
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

struct PostActionsView: View {
    
    @Binding var post: Post
    
    // There's a little bit of duplication of self.vote here as in *some* cases, a .onTapGesture wraps this view, and only the onTapGesture here can override that (button is not hit)
    var body: some View {
        HStack {
            let upVoteLabel = post.postVoteStatus == .downvoted ? nil : post.postScore.friendlyFormat()
            PostActionButton(systemIcon: "arrow.up", label: upVoteLabel, tintColor: Color.orange, isActive: post.postVoteStatus == .upvoted, action: { self.vote(.upvoted) })
                .onTapGesture {
                    self.vote(.upvoted)
                }
            
            let downVoteLabel = post.postVoteStatus == .downvoted ? post.postScore.friendlyFormat() : nil
            PostActionButton(systemIcon: "arrow.down", label: downVoteLabel, tintColor: Color.purple, isActive: post.postVoteStatus == .downvoted, action: { vote(.downvoted) })
                .onTapGesture {
                    self.vote(.downvoted)
                }
            
            Spacer()
            
            PostActionButton(systemIcon: "message", label: post.postCommentCount.friendlyFormat(), tintColor: .blue, isActive: false, action: {})

            PostActionButton(systemIcon: "bookmark", tintColor: .green, isActive: post.postFlagDetails.isSaved, action: { self.toggleSave() })
                .onTapGesture {
                    self.toggleSave()
                }
        }
        .padding(.horizontal, 8)
        .font(.subheadline)
        .bold()
    }
    
    private func vote(_ status: VoteStatus) {
        Task {
            let currentStatus = post.postVoteStatus
            let newStatus: VoteStatus = currentStatus == status ? .noVote : currentStatus == .noVote ? status : currentStatus.opposite()
            try? await PostService.Vote(on: post.postId, newStatus)
            
            withAnimation(.smooth) {
                post.postVoteStatus = newStatus
            }
            
            await MainActor.run {
                NotificationCenter.default.post(name: .ObjectVotedOn, object: nil, userInfo: ["objectId": post.postId, "voteStatus": newStatus])
                HapticService.start(.light)
            }
        }
    }
    
    private func toggleSave() {
        Task {
            let isSaved = post.postFlagDetails.isSaved
            withAnimation(.smooth) {
                post.postFlagDetails.isSaved.toggle()
            }
            
            try? await PostService.ToggleSave(postId: post.postId, !isSaved)
        }
    }
}
