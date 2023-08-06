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
    @State private var isCompact: Bool
    @State private var overrideTitle: String?
    
    init(url: String, overrideImage: String? = nil, fetchMetadata: Bool = true, isCompact: Bool = false, overrideTitle: String? = nil) {
        self.urlString = url
        self.overrideImageUrl = overrideImage
        self.isCompact = isCompact
        self.overrideTitle = overrideTitle
        if let cached = GlobalCaches.linkCache.get(url) {
            self.fetchMetadata = false
            self.metadata = cached
        } else {
            self.fetchMetadata = fetchMetadata
        }
    }
    
    
    var body: some View {
        ZStack {
            if isCompact {
                HStack {
                    urlImage()
                        .frame(width: 60, height: 60)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                    VStack {
                        if let title = overrideTitle {
                            Text(title)
                                .lineLimit(1)
                        }
                        Text(metadata?.url?.absoluteString ?? self.urlString)
                            .lineLimit(1)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .background(Color.layer2.overlay(Material.thick))
            } else {
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
                    await GlobalCaches.linkCache.set(metadata, forKey: urlString)
                    self.metadata = metadata
                }
                
                if let imageCached = await GlobalCaches.imageUrlDataCache.get(urlString) {
                    self.imageData = imageCached
                } else {
                    let _ = metadata?.imageProvider?.loadDataRepresentation(for: UTType.image, completionHandler: { data, error in
                        if let data {
                            self.imageData = data
                            Task {
                                await GlobalCaches.imageUrlDataCache.set(data, forKey: urlString)
                            }
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
                    .background(.gray)
            } placeholder: {
                Rectangle()
                    .redacted(reason: .placeholder)
            }
        } else if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(.gray)
        } else {
            Rectangle()
                .redacted(reason: .placeholder)
        }
    }
}
