//
//  MediaGalleryView.swift
//  GaryDit
//
//  Created by Tom Knighton on 09/07/2023.
//
import Foundation
import SwiftUI
import CoreMedia

struct MediaGalleryView: View {
    
    @Environment(RedditPostViewModel.self) private var postModel
    @Environment(\.dismiss) private var dismiss
    
    @GestureState private var draggingOffset: CGSize = .zero
    
    @State private var viewModel: MediaGalleryViewModel
    @State private var currentMediaViewModel: VideoPlayerViewModel? = nil
    @State private var overrideMediaPlaying: Bool = true
    
    init(selectedMediaUrl: String) {
        _viewModel = State(initialValue: MediaGalleryViewModel(initialTabUrl: selectedMediaUrl))
    }
    
    init(selectedMediaUrl: String, videoViewModel: VideoPlayerViewModel) {
        _viewModel = State(initialValue: MediaGalleryViewModel(initialTabUrl: selectedMediaUrl))
        currentMediaViewModel = videoViewModel
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(viewModel.backgroundOpacity)
                .ignoresSafeArea()
            
            GeometryReader { reader in
                TabView(selection: $viewModel.selectedTabUrl) {
                    ForEach(self.postModel.post.postContent.media, id: \.url) { media in
                        ZStack {
                            switch media.type ?? .image {
                            case .image:
                                ZoomableScrollView(scale: $viewModel.currentZoomScale, maxZoom: viewModel.maxZoomScale) {
                                    CachedImageView(url: media.url)
                                        .scaledToFit()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                            case .gif:
                                ZoomableScrollView(scale: $viewModel.currentZoomScale, maxZoom: viewModel.maxZoomScale) {
                                    GIFView(url: media.url, isPlaying: .constant(true))
                                        .aspectRatio(media.width / media.height, contentMode: .fit)
                                        .border(.red)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                            case .video:
                                ZStack {
                                    ZoomableScrollView(scale: $viewModel.currentZoomScale, maxZoom: viewModel.maxZoomScale) {
                                        PlayerView(viewModel: postModel.getMediaModelForUrl(media.url) ?? VideoPlayerViewModel(media: media), isPlaying: $overrideMediaPlaying)
                                            .aspectRatio(media.width / media.height, contentMode: .fit)
                                            .overlay(
                                                ZStack {
                                                    if let image = self.viewModel.scrubThumbnail {
                                                        Image(uiImage: image)
                                                            .resizable()
                                                            .aspectRatio(media.width / media.height, contentMode: .fit)
                                                    }
                                                }
                                            )
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                                
                            default:
                                EmptyView()
                            }
                        }
                        .offset(draggingOffset)
                        .tag(media.url)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: self.viewModel.displayControls ? .automatic : .never))
                .indexViewStyle(.page(backgroundDisplayMode: self.viewModel.displayControls ? .always : .interactive))
                .simultaneousGesture(exclusiveTapGestures())
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
                
                if let currentMedia = self.postModel.post.postContent.media.first(where: { $0.url == self.viewModel.selectedTabUrl }) {
                    MediaOverlayBar(media: currentMedia)
                        .padding(.horizontal, 16)
                }
                if let binding = Binding<VideoPlayerViewModel>($currentMediaViewModel) {
                    MediaControlsView(mediaViewModel: binding, galleryViewModel: $viewModel, previewImage: $viewModel.scrubThumbnail)
                }
                Spacer().frame(height: 40)
            }
            .opacity(self.viewModel.displayControls ? viewModel.backgroundOpacity : 0)

            
        }
        .opacity(viewModel.entireViewOpacity)
        .simultaneousGesture(dragAwayGesture($draggingOffset))
        .onChange(of: viewModel.selectedTabUrl, initial: true) {
            let vm = postModel.videoViewModels.first(where: { $0.media.url == viewModel.selectedTabUrl })
            self.currentMediaViewModel = vm
        }
        .onChange(of: currentMediaViewModel?.isPlaying, initial: true) {
            if currentMediaViewModel?.isPlaying == false {
                self.viewModel.controlTimeoutTask?.cancel()
            } else {
                self.viewModel.timeoutControls()
            }
        }
    }
}

extension MediaGalleryView {
    func dragAwayGesture(_ offset: GestureState<CGSize>) -> some Gesture {
        let gesture = DragGesture()
            .updating(offset) { value, outVal, _ in
                guard viewModel.currentZoomScale == 1 else {
                    return
                }
                
                if (viewModel.isScrubbing) {
                    DispatchQueue.main.async {
                        if value.translation.width < viewModel.scrubOffset.width { // Left swipe
                            viewModel.scrubProgress = max(0, viewModel.scrubProgress - 0.02)
                        } else if value.translation.width > viewModel.scrubOffset.width { // Right swipe
                            viewModel.scrubProgress = max(0, viewModel.scrubProgress + 0.02)
                        }
                        
                        viewModel.scrubThumbnail = self.currentMediaViewModel?.thumbnailFrames[safe: Int(min(99, viewModel.scrubProgress * 100))]
                        if let duration = self.currentMediaViewModel?.avPlayer?.currentItem?.duration {
                            self.currentMediaViewModel?.avPlayer?.seek(to: CMTime(seconds: Double(duration.seconds * viewModel.scrubProgress), preferredTimescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
                        }
                        viewModel.scrubOffset = value.translation
                    }
                    return
                }
            
                if self.currentMediaViewModel != nil && -30...30 ~= value.translation.height && (value.translation.width > 30 || value.translation.width < -30) {
                    outVal = .zero
                    DispatchQueue.main.async {
                        viewModel.isScrubbing = true
                        viewModel.scrubProgress = self.currentMediaViewModel?.currentProgress ?? 0
                        viewModel.wasMediaPlayingBeforeScrub = self.currentMediaViewModel?.isPlaying ?? false
                        self.currentMediaViewModel?.setIsPlaying(false)
                    }
                    return
                } else {
                    outVal = value.translation
                    
                    let halfHeight = UIScreen.main.bounds.height / 2
                    let progress = value.translation.height / halfHeight
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut) {
                            viewModel.backgroundOpacity = Double(1 - (progress < 0 ? -progress : progress))
                        }
                    }
                }
            }
            .onEnded { value in
                guard viewModel.currentZoomScale == 1 else {
                    return
                }
                
                DispatchQueue.main.async{
                    viewModel.isScrubbing = false
                    viewModel.scrubThumbnail = nil
                    self.currentMediaViewModel?.setIsPlaying(viewModel.wasMediaPlayingBeforeScrub)
                }

                var translation = value.translation.height
                
                if translation < 0 {
                    translation = -translation
                }
                
                if translation >= 250 {
                    viewModel.entireViewOpacity = 0
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        dismiss()
                    }
                }
                DispatchQueue.main.async {
                    viewModel.backgroundOpacity = 1
                }
            }
        
        return gesture
    }
}

extension MediaGalleryView {
    
    func exclusiveTapGestures() -> some Gesture {
        
        TapGesture(count: 2) // Double tap zoom
            .onEnded { _ in
                self.viewModel.doubleTapZoomGesture()
            }
            .exclusively(before:
                TapGesture(count: 1) // Single tap control toggle
                    .onEnded({ _ in
                        withAnimation(.easeInOut(duration: 0.35)) {
                            self.viewModel.displayControls.toggle()
                        }
                        
                        let currentUrl = self.postModel.post.postContent.media.first(where: { $0.url == self.viewModel.selectedTabUrl })
                        if (currentUrl?.mediaText == nil && self.currentMediaViewModel == nil) || self.currentMediaViewModel?.isPlaying == true {
                            self.viewModel.timeoutControls()
                        }
                })
            )
    }
}
