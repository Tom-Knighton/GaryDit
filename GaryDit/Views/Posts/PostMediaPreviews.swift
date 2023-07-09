//
//  PostMediaPreviews.swift
//  GaryDit
//
//  Created by Tom Knighton on 08/07/2023.
//

import SwiftUI

struct PostTopMediaView: View {
    
    var content: PostContent
    
    var body: some View {
        let media = content.media
        if let first = media.first {
            switch content.contentType {
            case .image:
                if first.url.contains(".gif") {
                    PostGifView(url: first.url, aspectRatio: first.width / first.height)
                } else {
                    PostImageView(media: first)
                }
            case .video:
                PostVideoView(url: first.url, aspectRatio: first.width / first.height)
            case .linkOnly:
                PostLinkView(url: first.url, thumbnailUrl: first.thumbnailUrl)
            case .mediaGallery:
               PostMediaGallery(media: media)
            default:
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
}

struct PostGifView: View {
    
    @State private var isPlayingMedia = false
    let url: String
    let aspectRatio: Double
    
    init(url: String, aspectRatio: Double = 1) {
        self.url = url
        self.aspectRatio = aspectRatio
    }
    
    var body: some View {
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
}

struct PostVideoView: View {
    @State private var isPlayingMedia = false
    let url: String
    let aspectRatio: Double
    
    init(url: String, aspectRatio: Double = 1) {
        self.url = url
        self.aspectRatio = aspectRatio
    }
    
    var body: some View {
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
}

struct PostImageView: View {
    
    let media: PostMedia
    
    var body: some View {
        VStack {
            if media.url.contains(".gif") {
                PostGifView(url: media.url, aspectRatio: media.width / media.height)
            } else {
                CachedImageView(url: media.url)
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

struct PostLinkView: View {
    
    let url: String
    let thumbnailUrl: String?
    
    var body: some View {
        LinkView(url: url, overrideImage: thumbnailUrl ?? "", fetchMetadata: false)
            .padding(.horizontal, 8)
            .padding(.top, 8)
    }
}

struct PostMediaGallery: View {
    
    let media: [PostMedia]
    
    var body: some View {
        let firstPreview = media.first
        let nextTwoPreviews = Array(media.dropFirst().prefix(2))
        
        if let firstPreview, nextTwoPreviews.isEmpty {
            if firstPreview.type == .image {
                PostImageView(media: firstPreview)
            } else {
                PostVideoView(url: firstPreview.url, aspectRatio: firstPreview.width / firstPreview.height)
            }
        } else {
            ZStack(alignment: .topLeading) {
                if let firstPreview {
                    Grid(horizontalSpacing: 2) {
                        GridRow {
                            if firstPreview.type == .image {
                                PostImageView(media: firstPreview)
                                    .aspectRatio(firstPreview.width / firstPreview.height, contentMode: .fill)
                                    .gridCellColumns(media.count > 2 ? 2 : 1)
                                    .clipShape(.rect(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 0, topTrailingRadius: 0))
                            }
                            
                            GeometryReader { reader in
                                VStack(spacing: 0) {
                                    ForEach(nextTwoPreviews, id: \.url) { preview in
                                        let previewType = preview.type ?? .image
                                        let index = nextTwoPreviews.firstIndex(where: { $0.url == preview.url })
                                        if previewType == .image {
                                            PostImageView(media: preview)
                                                .aspectRatio(preview.width / preview.height, contentMode: .fill)
                                                .frame(height: reader.size.height / (media.count > 2 ? 2 : 1))
                                                .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: media.count > 2 ? (index == 0 ? 0 : 10) : 10, topTrailingRadius: media.count > 2 ? (index == 1 ? 0 : 10) : 10))
                                        }
                                    }
                                }
                                .frame(height: reader.size.height)
                            }
                        }
                    }
                }
                GeometryReader { reader in
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(media.count) IMAGES")
                                .font(.system(size: 12))
                                .padding(8)
                                .background(.thickMaterial)
                                .clipShape(.rect(cornerRadius: 10))
                                .padding(4)
                        }
                    }
                    .frame(width: reader.size.width)
                }
            }
        }
    }
}
