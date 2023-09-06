//
//  CachedImage.swift
//  GaryDit
//
//  Created by Tom Knighton on 08/07/2023.
//

import SwiftUI
import NukeUI
import Nuke

struct CachedImageView: View {
    
    var url: String
    
    var processors: [ImageProcessing]? = nil
    
    init(url: String) {
        self.url = url
    }
    
    var body: some View {
        LazyImage(url: URL(string: url), transaction: .init(animation: .default)) { state in
            if let image = state.image {
                image.resizable()
            } else if state.error != nil {
                Color.gray.opacity(0.1)
                    .overlay(Image(systemName: "xmark.circle.fill").foregroundColor(.red))
            } else {
                ProgressView()
            }
        }
        .processors(processors)
    }
}
