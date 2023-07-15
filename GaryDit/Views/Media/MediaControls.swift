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
    @Binding var previewImage: UIImage?
    @State private var progress: CGFloat = 0.1
    @State private var isDragging: Bool = false
    
    @State private var lastKnownProgress: CGFloat = 0
        
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    
                    Button(action: { mediaViewModel.skip(seconds: -10) }) {
                        Image(systemName: "gobackward.10")
                            .resizable()
                            .frame(width: 22, height: 24)
                    }
                    .tint(.white)
                    
                    Button(action: { self.mediaViewModel.setIsPlaying(!self.mediaViewModel.isPlaying) }) {
                        Image(systemName: self.mediaViewModel.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .frame(width: 18, height: 24)
                    }
                    .tint(.white)
                    .contentTransition(.symbolEffect(.replace))
                    
                    Button(action: { mediaViewModel.skip(seconds: 10)}) {
                        Image(systemName: "goforward.10")
                            .resizable()
                            .frame(width: 22, height: 24)
                    }
                    .tint(.white)
                }
                HStack {
                    Slider(value: $progress, in: 0...1, step: 0.01) { editing in
                        self.mediaViewModel.avPlayer?.pause()
                        self.isDragging = editing
                        if let duration = self.mediaViewModel.avPlayer?.currentItem?.duration {
                            self.mediaViewModel.avPlayer?.seek(to: CMTime(seconds: Double(duration.seconds * progress), preferredTimescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
                        }
                        
                        if (!editing) {
                            self.previewImage = nil
                        }
                    }
                    .onChange(of: self.progress) {
                        if isDragging {
                            let thumbnailIndex = Int(progress / 0.01)
                            self.previewImage = self.mediaViewModel.thumbnailFrames[safe: min(thumbnailIndex, 99)]
                        }
                    }
                    .tint(.white)
                }
                .frame(height: 8)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Material.regular.opacity(0.8))
            .clipShape(.rect(cornerRadius: 15))
            .shadow(radius: 3)
            .environment(\.colorScheme, .dark)
            .onChange(of: self.mediaViewModel.currentProgress) {
                if !isDragging {
                    self.progress = self.mediaViewModel.currentProgress
                }
            }
            
            Spacer()
                .frame(height: 64)
        }
        .padding(.horizontal, 16)
    }
}


//
//#Preview {
//    @State var viewModel = RedditPostViewModel(post: Post(postId: "1", postAuthour: "Banging_Bananas", postSubreddit: "Test", postTitle: "A video!", postScore: 1, postCreatedAt: Date(), postEditedAt: nil, postFlagDetails: PostFlags(isNSFW: false, isSaved: false, isLocked: false, isStickied: false, isArchived: false, distinguishmentType: .none), postContent: PostContent(contentType: .video, textContent: nil, media: [PostMedia(url: "https://i.imgur.com/VDBaX2B.mp4", thumbnailUrl: nil, height: 250, width: 500, type: .video)])))
//    
//    return MediaGalleryView()
//        .environment(viewModel)
//        .background(BackgroundCleanerView())
//}
