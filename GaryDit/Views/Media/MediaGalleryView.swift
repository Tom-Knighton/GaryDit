//
//  MediaGalleryView.swift
//  GaryDit
//
//  Created by Tom Knighton on 09/07/2023.
//
import Foundation
import SwiftUI

struct MediaGalleryView: View {
    
    @Environment(RedditPostViewModel.self) private var postModel
    @Environment(\.dismiss) private var dismiss
    
    @GestureState var draggingOffset: CGSize = .zero
    
    @State private var bgOpacity: Double = 1
    @State private var entireOpacity: Double = 1
    
    @State private var isPlaying = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .opacity(bgOpacity)
            TabView {
                ForEach(self.postModel.post.postContent.media, id: \.url) { media in
                    ZStack {
                        switch media.type ?? .image {
                        case .image:
                            CachedImageView(url: media.url)
                                .aspectRatio(contentMode: .fit)
                            
                        case .video:
                            VStack{
                                PlayerView(url: media.url, isPlaying: $isPlaying)
                                    .aspectRatio(media.width / media.height, contentMode: .fit)
                            }
                               
                        default:
                            Text(":(")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(draggingOffset)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack(spacing: 0) {
                Spacer().frame(height: 16)
                HStack {
                    Spacer()
                    Button(action: { self.dismiss() }) {
                        Image(systemName: "xmark")
                            .frame(width: 30, height: 30)
                            .padding(4)
                            .background(.thickMaterial)
                            .shadow(radius: 3)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    Spacer().frame(width: 16)
                }
                Spacer()
            }
            .opacity(bgOpacity)
        }
        .opacity(entireOpacity)
        .gesture(DragGesture().updating($draggingOffset, body: { value, outVal, _ in
            outVal = value.translation

            let halfHeight = UIScreen.main.bounds.height / 2
            let progress = value.translation.height / halfHeight
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    self.bgOpacity = Double(1 - (progress < 0 ? -progress : progress))
                }
            }            
        }).onEnded({ value in
            var translation = value.translation.height
            
            if translation < 0 {
                translation = -translation
            }
            
            if translation >= 250 {
                self.entireOpacity = 0
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    self.dismiss()
                }
            }
            DispatchQueue.main.async {
                self.bgOpacity = 1
            }
        }))
    }
}
