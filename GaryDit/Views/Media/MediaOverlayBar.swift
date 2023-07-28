//
//  MediaOverlayBar.swift
//  GaryDit
//
//  Created by Tom Knighton on 22/07/2023.
//

import Foundation
import SwiftUI


struct MediaOverlayBar: View {
    
    let media: PostMedia
    
    var body: some View {
        if let text = media.mediaText {
            HStack {
                ScrollView {
                    Text(text)
                }
                .frame(maxHeight: 150)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Material.thin)
            .environment(\.colorScheme, .dark)
            .clipShape(.rect(cornerRadius: 10))
            .shadow(radius: 3)
        } else {
            EmptyView()
        }
        
    }
}


//#Preview {
//    var media = PostMedia(url: "https://i.imgur.com/WYoD0Tx.jpg", thumbnailUrl: "https://i.imgur.com/WYoD0Tx.jpg", height: 2268, width: 4032, type: .image, hlsDashUrl: nil, mediaText: "Test fitting riser 2. This is a complete \"set\". Always have to work 1 riser ahead because the tread above it will wrap over the top of the riser below it.")
//    
//    return MediaOverlayBar(media: media)
//}

