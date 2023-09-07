//
//  PostCommentView.swift
//  GaryDit
//
//  Created by Tom Knighton on 04/08/2023.
//

import Foundation
import SwiftUI
import MarkdownView

struct PostCommentView: View {
    
    @State private var isCollapsed: Bool = false
    
    public var comment: PostComment
    public var postId: String
    public var postAuthour: String
    
    var nestLevel: Double = 0
    
    var body: some View {
        VStack {
            Spacer().frame(height: 4)
            HStack {
                if nestLevel > 0 {
                    RoundedRectangle(cornerRadius: 1.5)
                        .padding(.vertical, 6)
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
                        Divider()
                        HStack {
                            HStack(spacing: 2) {
                                Text(comment.commentAuthour)
                                    .bold()
                                    .foregroundStyle(getUsernameColour())
                                self.commentFlagViews()
                            }
                            
                            
                            HStack(spacing: 1) {
                                Image(systemName: "arrow.up")
                                Text(String(describing: comment.commentScore))
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .bold()
                            }
                            if comment.commentEditedAt != nil {
                                Image(systemName: "pencil")
                            }
                            Text((comment.commentEditedAt ?? comment.commentCreatedAt).friendlyAgo)
                            
                            if self.isCollapsed {
                                HStack {
                                    Text(String(describing: self.comment.getTotalCommentCount() + 1))
                                    Image(systemName: "chevron.down")
                                }
                                .padding(.all, 4)
                                .background(Material.ultraThick)
                                .clipShape(.rect(cornerRadius: 10))
                                
                                Spacer().frame(width: 8)
                            }
                        }
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                        .tint(.gray)
                        .padding(.bottom, 4)
                        
                        if !self.isCollapsed {
                            MarkdownView(text: .constant(comment.commentText))
                                .imageProvider(CustomImageProvider(medias: self.comment.media), forURLScheme: "https")
                                .font(.body, for: .blockQuote)
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
        .padding(.leading, nestLevel * 2.5)
        .background(Color.layer1)
        .onTapGesture {
            guard self.comment.loadMoreLink == nil else {
                return
            }
            
            withAnimation(.snappy) {
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
        if self.comment.commentAuthour == "Banging_Bananas" {
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
        
        if self.comment.commentAuthour == authour {
            return .blue
        }
        
        return .primary
    }
    
    @ViewBuilder
    func commentFlagViews() -> some View {
        let flags = self.comment.commentFlagDetails
        
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

struct CustomImageProvider: ImageDisplayable {
    
    private var inlineMedias: [PostMedia]
    init(medias: [PostMedia]) {
        self.inlineMedias = medias
    }
    
    func getInlineMedia(for url: String) -> PostMedia? {
        return inlineMedias.first(where: { $0.url == url && $0.isInline == true })
    }
    
    func getAspectRatio(url: String) -> Double {
        
        if let cached = GlobalCaches.gifAspectRatioCAche.get(url) {
            return cached
        }
        
        let media = getInlineMedia(for: url)
        if let media {
            let ratio = media.width / media.height
            Task {
                await GlobalCaches.gifAspectRatioCAche.set(ratio, forKey: url)
            }
            return ratio
        }
        
        return 1.75
    }
    
    func makeImage(url: URL, alt: String?) -> some View {
        let ratio = getAspectRatio(url: url.absoluteString)
        ZStack {
            Rectangle()
                .fill(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(ratio, contentMode: .fit)
            GIFView(url: url.absoluteString, isPlaying: .constant(true))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(ratio, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 10))
                .shadow(radius: 3)
        }
        
    }
}
