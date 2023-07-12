//
//  CachedImage.swift
//  GaryDit
//
//  Created by Tom Knighton on 08/07/2023.
//

import SwiftUI

struct CachedImageView: View {
    
    var url: String
    var thumbnailUrl: String?
    var displayThumbnail: Binding<Bool>
    @State private var uiImage: UIImage?
    
    private var imageCache = Cache<String, UIImage>()
    
    init(url: String, thumbnailUrl: String? = nil) {
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.displayThumbnail = .constant(false)
    }
    
    init(url: String, thumbnailUrl: String? = nil, displayThumbnail: Binding<Bool> = .constant(false)) {
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.displayThumbnail = displayThumbnail
    }
    
    var body: some View {
        ZStack {
            if let image = self.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .allowedDynamicRange(.high)
            } else {
                ProgressView()
            }
        }
        .task {
            await self.load()
        }
        
    }
    
    @Sendable
    private func load() async {
        if let image = self.imageCache.get(url) {
            self.uiImage = image
        } else {
            guard let url = URL(string: url) else { return }
            if let (urlData, _) = try? await URLSession.shared.data(from: url) {
                self.uiImage = UIImage(data: urlData)
            }
        }
    }
}
