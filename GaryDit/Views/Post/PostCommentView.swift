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
    
    @Binding public var comment: PostComment
    
    var body: some View {
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
            
            MarkdownView(text: .constant(comment.commentText))
                .imageProvider(CustomImageProvider(medias: self.comment.media), forURLScheme: "https")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(comment.media.filter { $0.isInline == false }, id: \.url) { media in
                LinkView(url: media.url, fetchMetadata: true, isCompact: true)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.layer1)
    }
    
    
}

struct CustomImageProvider: ImageDisplayable {
    
    private var inlineMedias: [PostMedia]
    init(medias: [PostMedia]) {
        print("loading with media count \(medias.count)")
        self.inlineMedias = medias
        print(medias.first?.url)
    }
    
    func getInlineMedia(for url: String) -> PostMedia? {
        let mapped = inlineMedias.compactMap({ $0.url })
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
