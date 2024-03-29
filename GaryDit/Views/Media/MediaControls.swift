//
//  MediaControls.swift
//  GaryDit
//
//  Created by Tom Knighton on 12/07/2023.
//

import Foundation
import SwiftUI
import CoreMedia

struct MediaControlsView: View {
        
    @Binding var mediaViewModel: VideoPlayerViewModel
    @Binding var galleryViewModel: MediaGalleryViewModel
    @Binding var previewImage: UIImage?
    @State private var progress: CGFloat = 0.1
    
    @State private var lastKnownProgress: CGFloat = 0
    @State private var shouldUnpauseAfterScrub: Bool = false
        
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                HStack(spacing: 30) {
                    
                    Spacer()
                    Button(action: { mediaViewModel.skip(seconds: -10); galleryViewModel.timeoutControls() }) {
                        Image(systemName: "gobackward.10")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .tint(.white)
                    
                    Button(action: { self.mediaViewModel.setIsPlaying(!self.mediaViewModel.isPlaying); galleryViewModel.timeoutControls() }) {
                        if self.mediaViewModel.isPlaying { // iOS 17 bug prevents ternary from working here for some reason :(
                            Image(systemName: "pause.fill")
                                .resizable()
                                .frame(width: 18, height: 24)
                        } else {
                            Image(systemName: "play.fill")
                                .resizable()
                                .frame(width: 18, height: 24)
                        }
                        
                    }
                    .tint(.white)
                    
                    Button(action: { mediaViewModel.skip(seconds: 10); galleryViewModel.timeoutControls() }) {
                        Image(systemName: "goforward.10")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .tint(.white)
                    
                    Spacer()
                }
                
                if mediaViewModel.mediaHasAudio {
                    HStack {
                        Spacer()
                        Button(action: { mediaViewModel.toggleMute(); galleryViewModel.timeoutControls() }) {
                            if mediaViewModel.mediaIsMuted { // iOS 17 bug prevents ternary from working here for some reason :(
                                Image(systemName: "speaker.slash.fill" )
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "speaker.wave.3.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                            }
                            
                        }
                        .tint(.white)
                        Spacer().frame(width: 8)
                    }
                }
            }
           
            HStack {
                Slider(value: $progress, in: 0...1, step: 0.01) { editing in
                    if editing {
                        self.shouldUnpauseAfterScrub = self.mediaViewModel.isPlaying
                    }
                    
                    self.mediaViewModel.setIsPlaying(false)
                    self.mediaViewModel.isScrubbing = editing
                    if let duration = self.mediaViewModel.avPlayer?.currentItem?.duration {
                        self.mediaViewModel.avPlayer?.seek(to: CMTime(seconds: Double(duration.seconds * progress), preferredTimescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
                    }
                    
                    if (!editing) {
                        self.previewImage = nil
                        self.mediaViewModel.setIsPlaying(self.shouldUnpauseAfterScrub)
                    }
                }
                .onChange(of: self.progress) {
                    if mediaViewModel.isScrubbing {
                        let thumbnailIndex = Int(progress / 0.01)
                        self.previewImage = self.mediaViewModel.thumbnailFrames[safe: min(thumbnailIndex, 99)]
                    }
                }
                .tint(.white)
            }
            .frame(height: 8)
            
            HStack {
                let currentTime = mediaViewModel.isScrubbing ? (self.progress * mediaViewModel.mediaDuration) : mediaViewModel.mediaTimePlayed
                Text(currentTime.asString(style: .positional))
                    .font(.footnote)
                    .padding(.all, 0)
                    .monospacedDigit()
                Spacer()
                Text("-" + (self.mediaViewModel.mediaTimeLeft.asString(style: .positional)))
                    .font(.footnote)
                    .padding(.all, 0)
                    .monospacedDigit()
            }
            .padding(.top, -8)
        }
        .padding([.top, .leading, .trailing], 12)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(Material.regular.opacity(0.8))
        .clipShape(.rect(cornerRadius: 15))
        .shadow(radius: 3)
        .environment(\.colorScheme, .dark)
        .onChange(of: self.mediaViewModel.currentProgress) {
            if !mediaViewModel.isScrubbing {
                self.progress = self.mediaViewModel.currentProgress
            }
        }
        .padding(.horizontal, 16)
    }
}


//
//#Preview {
//    @State var viewModel = RedditPostViewModel(post: Post(postId: "1", postAuthour: "Banging_Bananas", postSubreddit: "Test", postTitle: "A video!", postScore: 1, postCreatedAt: Date(), postEditedAt: nil, postFlagDetails: PostFlags(isNSFW: false, isSaved: false, isLocked: false, isStickied: false, isArchived: false, distinguishmentType: .none), postContent: PostContent(contentType: .video, textContent: nil, media: [PostMedia(url: "https://i.imgur.com/VDBaX2B.mp4", thumbnailUrl: nil, height: 250, width: 500, type: .video, hlsDashUrl: nil)])))
//    
//    return MediaGalleryView()
//        .environment(viewModel)
//        .background(BackgroundCleanerView())
//}
