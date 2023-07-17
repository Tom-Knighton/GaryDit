//
//  LinkView.swift
//  GaryDit
//
//  Created by Tom Knighton on 20/06/2023.
//

import Foundation
import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

struct LinkView: View {
    
    @State private var metadata: LPLinkMetadata?
    @State private var urlString: String
    @State private var overrideImageUrl: String?
    @State private var fetchMetadata: Bool = true
    @State private var imageData: Data?
    
    init(url: String, overrideImage: String? = nil, fetchMetadata: Bool = true) {
        self.urlString = url
        self.overrideImageUrl = overrideImage
        
        if let cached = GlobalCaches.linkCache.get(url) {
            self.fetchMetadata = false
            self.metadata = cached
        } else {
            self.fetchMetadata = fetchMetadata
        }
    }
    
    var body: some View {
        ZStack {
            urlImage()
            VStack {
                Spacer()
                HStack {
                    if let host = metadata?.url?.host() ?? URL(string: self.urlString)?.host() {
                        Text(host.replacingOccurrences(of: "www.", with: ""))
                            .bold()
                        Divider()
                    }
                    Text(metadata?.url?.absoluteString ?? self.urlString)
                }
                .frame(maxHeight: 20)
                .font(.system(size: 12))
                .lineLimit(1)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Material.regular)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .task {
            Task.detached {
                if !self.fetchMetadata {
                    return
                }
                
                if let cached = GlobalCaches.linkCache.get(urlString) {
                    self.metadata = cached
                } else {
                    guard let url = URL(string: urlString) else {
                        return
                    }
                    
                    let provider = LPMetadataProvider()
                    let metadata = try? await provider.startFetchingMetadata(for: url)
                    GlobalCaches.linkCache.set(metadata, forKey: urlString)
                    self.metadata = metadata
                }
                
                if let imageCached = GlobalCaches.imageUrlDataCache.get(urlString) {
                    self.imageData = imageCached
                } else {
                    let _ = metadata?.imageProvider?.loadDataRepresentation(for: UTType.image, completionHandler: { data, error in
                        if let data {
                            self.imageData = data
                            GlobalCaches.imageUrlDataCache.set(data, forKey: urlString)
                        }
                    })
                }
            }
        }
    }
    
    @ViewBuilder
    func urlImage() -> some View {
        
        if !self.fetchMetadata, let overrideUrl = URL(string: overrideImageUrl ?? "") {
            AsyncImage(url: overrideUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .redacted(reason: .placeholder)
            }
        } else if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Rectangle()
        }
    }
}
