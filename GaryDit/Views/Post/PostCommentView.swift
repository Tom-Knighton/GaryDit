//
//  PostCommentView.swift
//  GaryDit
//
//  Created by Tom Knighton on 04/08/2023.
//

import Foundation
import SwiftUI
import RedditMarkdownView

struct PostCommentView: View {
    
    @State private var isCollapsed: Bool = false
    @State private var likeState: VoteStatus = .noVote
    
    public var comment: PostComment
    public var postId: String
    public var postAuthour: String
    
    var nestLevel: Double = 0
    
    var onCommentLiked: ((_: String, _: VoteStatus) -> Void)? = nil
    
    var body: some View {
        VStack {
            if self.isCollapsed == false && self.comment.loadMoreLink == nil && nestLevel != 0 {
                Divider()
            }
            Spacer().frame(height: 4)
            
            SwipeView {
                commentContent()
                    .padding(.leading, nestLevel * 2.5)
                    .contentShape(.rect())

            } leadingActions: { context in
                let isSecond = context.currentDragDistance > 250
                SwipeAction(systemImage: isSecond ? (comment.commentFlagDetails.isSaved ? "bookmark.slash.fill" : "bookmark.slash") : "arrow.down", backgroundColor: isSecond ? .green : .purple, action: {
                    if isSecond {
                        withAnimation() {
                            self.isCollapsed.toggle()
                        }
                    } else {
                        self.vote(.downvoted)
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
                SwipeAction(systemImage: isSecond ? "chevron.up.chevron.down" : "arrow.up", backgroundColor: isSecond ? .blue : .orange, action: {
                    if isSecond {
                        withAnimation(.smooth) {
                            self.isCollapsed.toggle()
                        }
                    } else {
                        self.vote(.upvoted)
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
            .swipeActionCornerRadius(25)
            .allowSwipeToTrigger()
            
            if !self.isCollapsed {
                LazyVStack {
                    ForEach(comment.replies, id: \.commentId) { reply in
                        PostCommentView(comment: reply, postId: postId, postAuthour: postAuthour, nestLevel: self.nestLevel + 1)
                    }
                }
            }
        }
        .padding(.all, nestLevel == 0 ? 8 : 0)
        .background(Color.layer2)
        .clipShape(.rect(cornerRadius: 10))
        .onTapGesture {
            guard self.comment.loadMoreLink == nil else {
                return
            }
            
            withAnimation(.smooth) {
                self.isCollapsed.toggle()
            }
        }
        .onAppear {
            self.likeState = comment.voteStatus
        }
    }
    
    func getNestLevelColor(nestLevel: Int) -> Color {
        let colours: [Color] = [
            Color.red,
            Color.orange,
            Color.yellow,
            Color.green,
            Color.blue,
            Color.indigo,
            Color.purple
        ]
        
        return colours[(nestLevel - 1) % colours.count]
    }    
    
    @ViewBuilder
    func commentContent() -> some View {
        HStack {
            if nestLevel > 0 {
                RoundedRectangle(cornerRadius: 1.5)
                    .padding(.vertical, 2)
                    .frame(width: 2)
                    .foregroundStyle(getNestLevelColor(nestLevel: Int(self.nestLevel)))
            }
            if let loadMoreLink = comment.loadMoreLink {
                VStack {
                    Divider()
                    MoreCommentsView(commentId: comment.commentId, link: loadMoreLink)
                    Spacer().frame(height: 4)
                }
            } else {
                VStack {
                    HStack {
                        HStack(spacing: 2) {
                            Text(comment.commentAuthor)
                                .bold()
                                .foregroundStyle(getUsernameColour())
                                .fixedSize(horizontal: true, vertical: false)
                            self.commentFlagViews()
                        }
                        
                        Spacer()
                        
                        let tint: Color = likeState == .upvoted ? .orange : likeState == .downvoted ? .purple : .gray
                        HStack(spacing: 1) {
                            Image(systemName: comment.voteStatus == .downvoted ? "arrow.down" : "arrow.up")
                            Text(comment.commentScore.friendlyFormat())
                        }
                        .foregroundStyle(tint)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.layer3)
                        .clipShape(.rect(cornerRadius: 15))
                        .font(.caption)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            
                        }

                        HStack(spacing: 2) {
                            Image(systemName: comment.commentEditedAt == nil ? "clock" : "pencil")
                            Text((comment.commentEditedAt ?? comment.commentCreatedAt).friendlyAgo)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.layer3)
                        .clipShape(.rect(cornerRadius: 15))
                        .font(.caption)
                        
                        if self.isCollapsed {
                            HStack {
                                Text(String(describing: self.comment.getTotalCommentCount() + 1))
                                Image(systemName: "chevron.down")
                            }
                            .padding(.all, 4)
                            .background(Material.ultraThick)
                            .clipShape(.rect(cornerRadius: 10))
                            .font(.caption)
                            
                            Spacer().frame(width: 8)
                        }
                    }
                    .foregroundStyle(.gray)
                    .font(.subheadline)
                    .tint(.gray)
                    .padding(.bottom, 4)
                    
                    if !self.isCollapsed {
                        SnudownView(text: comment.commentText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .snudownDisplayInlineImages(false)
                        
                        ForEach(comment.media.filter { $0.isInline == false }, id: \.url) { media in
                            LinkView(url: media.url, imageUrl: media.thumbnailUrl, overrideTitle: media.mediaText, isCompact: true)
                        }
                    }

                    Spacer().frame(height: 4)
                }
            }
        }
    }
    
    private func vote() {
        let currentStatus = comment.voteStatus
        let newStatus: VoteStatus = currentStatus == .noVote ? .upvoted : currentStatus == .upvoted ? .downvoted : .noVote
        self.likeState = newStatus
        if let onCommentLiked {
            onCommentLiked(comment.commentId, newStatus)
        } else {
            Task {
                try? await PostService.Vote(on: postId, commentId: comment.commentId, newStatus)
            }
        }
    }
    
    private func vote(_ status: VoteStatus) {
        let currentStatus = comment.voteStatus
        let newStatus: VoteStatus = currentStatus == status ? .noVote : status
        self.likeState = newStatus
        if let onCommentLiked {
            onCommentLiked(comment.commentId, newStatus)
        } else {
            Task {
                try? await PostService.Vote(on: postId, commentId: comment.commentId, newStatus)
            }
        }
    }
}

extension PostCommentView {
    
    /// Returns the colour that the username should be displayed in on a comment
    public func getUsernameColour() -> Color {
        let authour = self.postAuthour
        if self.comment.commentAuthor == "Banging_Bananas" {
            return .purple
        }
        
        switch self.comment.commentFlagDetails.distinguishmentType {
        case .moderator:
            return .green
        case .admin:
            return .red
        case .special:
            return .red
        case .none:
            break
        }
        
        if self.comment.commentAuthor == authour {
            return .blue
        }
        
        return .primary
    }
    
    @ViewBuilder
    func commentFlagViews() -> some View {
        let flags = self.comment.commentFlagDetails
        
        if let flair = self.comment.commentAuthorFlair, flair.isEmpty == false {
            FlairView(flairText: flair)
                .lineLimit(1)
        }
        
        if flags.isStickied {
            Text(Image(systemName: "pin.fill"))
                .foregroundStyle(.green)
        }
        if flags.isLocked {
            Text(Image(systemName: "lock.fill"))
                .foregroundStyle(.yellow)
        }
        if flags.isArchived { 
            Text(Image(systemName: "archivebox.fill"))
                .foregroundStyle(.yellow)
        }
        if flags.isSaved {
            Text(Image(systemName: "bookmark.fill"))
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    ZStack {
        Color.layer1.ignoresSafeArea()
        LazyVStack {
            PostCommentView(comment: PostComment(commentId: "1", commentAuthor: "Banging_Bananas", commentAuthorFlair: nil, commentScore: 1, commentText: "Testing", commentCreatedAt: Date(), commentEditedAt: nil, voteStatus: .downvoted, commentFlagDetails: PostFlags(isNSFW: false, isSaved: false, isLocked: false, isStickied: false, isArchived: false, isSpoiler: false, distinguishmentType: .none), replies: [PostComment(commentId: "1", commentAuthor: "Banging_Bananas", commentAuthorFlair: nil, commentScore: 1, commentText: "Testing", commentCreatedAt: Date(), commentEditedAt: nil, voteStatus: .noVote, commentFlagDetails: PostFlags(isNSFW: false, isSaved: false, isLocked: false, isStickied: false, isArchived: false, isSpoiler: false, distinguishmentType: .none), replies: [PostComment(commentId: "1", commentAuthor: "Banging_Bananas", commentAuthorFlair: nil, commentScore: 1, commentText: "Testing", commentCreatedAt: Date(), commentEditedAt: Date(), voteStatus: .upvoted, commentFlagDetails: PostFlags(isNSFW: false, isSaved: false, isLocked: false, isStickied: false, isArchived: false, isSpoiler: false, distinguishmentType: .none), replies: [], loadMoreLink: nil, media: [])], loadMoreLink: nil, media: [])], loadMoreLink: nil, media: []), postId: "1", postAuthour: "Banging_Bananas", nestLevel: 0)
        }
        .contentMargins([.horizontal], 16)
    }
    
    
}
