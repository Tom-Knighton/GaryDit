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
    
    public var comment: PostComment
    public var postId: String
    
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
                            Text(comment.commentAuthour)
                                .bold()
                                .foregroundStyle(.primary)
                            
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
                        }
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                        .tint(.gray)
                        .padding(.bottom, 4)
                        
                        MarkdownView(text: .constant(comment.commentText))
                            .imageProvider(CustomImageProvider(medias: self.comment.media), forURLScheme: "https")
                            .font(.body, for: .blockQuote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(comment.media.filter { $0.isInline == false }, id: \.url) { media in
                            LinkView(url: media.url, fetchMetadata: true, isCompact: true, overrideTitle: media.mediaText)
                        }
                        Spacer().frame(height: 4)
                    }
                }
                
            }
            
            ForEach(comment.replies, id: \.commentId) { reply in
                PostCommentView(comment: reply, postId: postId, nestLevel: self.nestLevel + 1)
            }
        }
        .padding(.leading, nestLevel * 2.5)
        .background(Color.layer1)
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
