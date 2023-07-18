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
    
    @GestureState private var draggingOffset: CGSize = .zero
    
    @State private var isScrubbing: Bool = false
    @State private var currentZoomScale: CGFloat = 1
    @State private var maxZoomScale: CGFloat = 10
    @State private var bgOpacity: Double = 1
    @State private var entireOpacity: Double = 1
    
    @State private var currentMediaViewModel: VideoPlayerViewModel? = nil
    @State private var tabSelectedIndex: String = ""
    @State private var draggingThumbnail: UIImage? = nil
    
    init(selectedMediaUrl: String) {
        _tabSelectedIndex = State(initialValue: selectedMediaUrl)
    }
    
    init(selectedMediaUrl: String, videoViewModel: VideoPlayerViewModel) {
        _tabSelectedIndex = State(initialValue: selectedMediaUrl)
        currentMediaViewModel = videoViewModel
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation(.easeInOut(duration: 1)) {
                self.currentZoomScale = currentZoomScale == 1 ? maxZoomScale / 2 : 1
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(bgOpacity)
                .ignoresSafeArea()
            
            GeometryReader { reader in
                TabView(selection: $tabSelectedIndex) {
                    ForEach(self.postModel.post.postContent.media, id: \.url) { media in
                        ZStack {
                            switch media.type ?? .image {
                            case .image:
                                ZoomableScrollView(scale: $currentZoomScale, maxZoom: maxZoomScale) {
                                    CachedImageView(url: media.url)
                                        .scaledToFit()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .gesture(doubleTapGesture)
                            case .gif:
                                ZoomableScrollView(scale: $currentZoomScale, maxZoom: maxZoomScale) {
                                    GIFView(url: media.url, isPlaying: .constant(true))
                                        .aspectRatio(media.width / media.height, contentMode: .fit)
                                        .border(.red)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .gesture(doubleTapGesture)
                            case .video:
                                ZStack {
                                    ZoomableScrollView(scale: $currentZoomScale, maxZoom: maxZoomScale) {
                                        PlayerView(viewModel: postModel.getMediaModelForUrl(media.url) ?? VideoPlayerViewModel(media: media))
                                            .aspectRatio(media.width / media.height, contentMode: .fit)
                                            .overlay(
                                                ZStack {
                                                    if let image = self.draggingThumbnail {
                                                        Image(uiImage: image)
                                                            .resizable()
                                                            .aspectRatio(media.width / media.height, contentMode: .fit)
                                                    }
                                                }
                                            )
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .gesture(doubleTapGesture)
                                
                            default:
                                EmptyView()
                            }
                        }
                        .offset(draggingOffset)
                        .tag(media.url)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            
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
            
            if let binding = Binding<VideoPlayerViewModel>($currentMediaViewModel) {
                MediaControlsView(mediaViewModel: binding, previewImage: $draggingThumbnail)
                    .opacity(bgOpacity)
            }
        }
        .opacity(entireOpacity)
        .simultaneousGesture(dragAwayGesture($draggingOffset))
        .onAppear {
            if self.currentMediaViewModel == nil {
                let vm = postModel.videoViewModels.first(where: { $0.media.url == self.tabSelectedIndex })
                self.currentMediaViewModel = vm
            }
        }
        .onChange(of: self.tabSelectedIndex) {
            let vm = postModel.videoViewModels.first(where: { $0.media.url == tabSelectedIndex })
            self.currentMediaViewModel = vm
        }
    }
}

extension MediaGalleryView {
    func dragAwayGesture(_ offset: GestureState<CGSize>) -> some Gesture {
        let gesture = DragGesture()
            .updating(offset) { value, outVal, _ in
                guard self.currentZoomScale == 1 else {
                    return
                }
                
                if (self.isScrubbing) {
                    //Do scrubbing logic instead....
                    return
                }
            
                if -30...30 ~= value.translation.height && (value.translation.width > 30 || value.translation.width < -30) {
                    outVal = .zero
                    DispatchQueue.main.async {
                        self.isScrubbing = true
                    }
                    return
                } else {
                    print(value.translation.height)
                    print(value.translation.width)
    //
    //                switch(value.translation.width, value.translation.height) {
    //                    case (...0, -30...30): return //left swipe
    //                    case (0..., -30...30): return //right swipe
    //                    default: break
    //                }
                    
                    outVal = value.translation
                    
                    let halfHeight = UIScreen.main.bounds.height / 2
                    let progress = value.translation.height / halfHeight
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            bgOpacity = Double(1 - (progress < 0 ? -progress : progress))
                        }
                    }
                }
            }
            .onEnded { value in
                guard self.currentZoomScale == 1 else {
                    return
                }
                
                self.isScrubbing = false
                var translation = value.translation.height
                
                if translation < 0 {
                    translation = -translation
                }
                
                if translation >= 250 {
                    entireOpacity = 0
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        dismiss()
                    }
                }
                DispatchQueue.main.async {
                    bgOpacity = 1
                }
            }
        
        return gesture
    }
}
