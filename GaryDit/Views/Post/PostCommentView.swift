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
    
    public var comment: PostComment
    public var postId: String
    public var postAuthour: String
    
    var nestLevel: Double = 0
    
    var body: some View {
        VStack {
            if self.isCollapsed == false && self.comment.loadMoreLink == nil && nestLevel != 0 {
                Divider()
            }
            Spacer().frame(height: 4)
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
                                self.commentFlagViews()
                            }
                            
                            Spacer()
                            
                            let tint: Color = comment.voteStatus == .upvoted ? .orange : comment.voteStatus == .downvoted ? .purple : .gray
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
                            
                            ForEach(comment.media.filter { $0.isInline == false }, id: \.url) { media in
                                LinkView(url: media.url, imageUrl: media.thumbnailUrl, overrideTitle: media.mediaText, isCompact: true)
                            }
                        }

                        Spacer().frame(height: 4)
                    }
                }
            }
            
            if !self.isCollapsed {
                ForEach(comment.replies, id: \.commentId) { reply in
                    PostCommentView(comment: reply, postId: postId, postAuthour: postAuthour, nestLevel: self.nestLevel + 1)
                }
            }
        }
        .padding(.all, nestLevel == 0 ? 8 : 0)
        .padding(.leading, nestLevel * 2.5)
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
        
        if let flair = self.comment.commentAuthorFlair {
            FlairView(flairText: flair)
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
