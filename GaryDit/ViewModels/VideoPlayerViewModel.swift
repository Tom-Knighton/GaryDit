//
//  VideoPlayerViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 13/07/2023.
//

import Foundation
import Observation
import SwiftUI
import AVFoundation
import CoreMedia

@Observable
class VideoPlayerViewModel {
    
    public var url: String
    @ObservationIgnored public var avPlayer: AVPlayer?
    public var currentTime: Double = 0
    public var currentProgress: Double = 0
    public var isPlaying: Bool = false
    public var thumbnailFrames: [UIImage] = []

    private var timeObserver: Any?
    private var hasTriedThumbnails = false
    
    
    init(url: String) {
        self.url = url
    }
    
    public func setAvPlayer(_ to: AVPlayer) {
        self.avPlayer = to
        
        if let existingObserver = timeObserver {
            self.avPlayer?.removeTimeObserver(existingObserver)
        }

        self.timeObserver = self.avPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 1000), queue: .main, using: { [weak self] time in
            guard self?.avPlayer?.currentItem?.status == .readyToPlay else {
                return
            }
            
            if self?.hasTriedThumbnails == false {
                self?.hasTriedThumbnails = true
                self?.generateThumbnails()
            }
            
            self?.currentTime = time.seconds
            self?.currentProgress = time.seconds / (self?.avPlayer?.totalDuration ?? 0)
        })
    }
    
    private func generateThumbnails() {
        Task.detached(priority: .userInitiated) {
            guard let item = self.avPlayer?.currentItem else { return }
            let asset = item.asset
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.requestedTimeToleranceAfter = .zero
            generator.requestedTimeToleranceBefore = .zero
            generator.appliesPreferredTrackTransform = true
            
            let totalDuration = try await asset.load(.duration).seconds
            var frameTimes: [CMTime] = []
            
            for progress in stride(from: 0, to: 1, by: 0.01) {
                let time = CMTime(seconds: progress * totalDuration, preferredTimescale: 1000)
                frameTimes.append(time)
            }
            
            for await result in generator.images(for: frameTimes) {
                if let cgImage = try? result.image {
                    await MainActor.run {
                        self.thumbnailFrames.append(UIImage(cgImage: cgImage))
                    }
                } else if let previous = self.thumbnailFrames[safe: self.thumbnailFrames.count - 1] {
                    self.thumbnailFrames.append(previous)
                }
            }
        }
    }
    
    public func setIsPlaying(_ to: Bool) {
        self.isPlaying = to
    }
}
