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
import Combine

@Observable
class VideoPlayerViewModel {
    
    public var media: PostMedia
    @ObservationIgnored public var avPlayer: AVPlayer?
    public var currentProgress: Double = 0
    public var isPlaying: Bool = false
    public var thumbnailFrames: [UIImage] = []
    public var isScrubbing: Bool = false
    public var mediaDuration: Double = 0
    
    public var mediaTimePlayed: Double {
        return currentTime
    }
    
    public var mediaTimeLeft: Double {
        return Double(max(0, (Int(self.avPlayer?.currentItem?.duration.seconds ?? 0)) - Int(mediaTimePlayed)))
    }

    private var timeObserver: Any?
    private var pauseCancellable: AnyCancellable?
    private var hasTriedThumbnails = false
    
    private var currentTime: Double = 0
    
    
    init(media: PostMedia) {
        self.media = media
    }
    
    public func setAvPlayer(_ to: AVPlayer) {
        self.avPlayer = to
        
        if let existingObserver = timeObserver {
            self.avPlayer?.removeTimeObserver(existingObserver)
        }
        
        self.pauseCancellable?.cancel()
        self.pauseCancellable = nil
        
        self.timeObserver = self.avPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 1000), queue: .main, using: { [weak self] time in
            guard self?.avPlayer?.currentItem?.status == .readyToPlay else {
                return
            }
            
            if self?.hasTriedThumbnails == false {
                self?.hasTriedThumbnails = true
                self?.generateThumbnails()
                self?.mediaDuration = self?.avPlayer?.currentItem?.duration.seconds ?? 0
            }
            
            self?.currentTime = time.seconds
            self?.currentProgress = time.seconds / (self?.avPlayer?.totalDuration ?? 0)
        })
        
        self.pauseCancellable = self.avPlayer?.publisher(for: \.timeControlStatus)
            .sink { [unowned self] status in
                self.isPlaying = status == .playing
            }
    }
    
    private func generateThumbnails() {
        Task.detached(priority: .userInitiated) {
            
            var item = self.avPlayer?.currentItem
            
            if let dashPreview = self.media.hlsDashUrl, let dashPreviewUrl = URL(string: dashPreview) {
                let previewAV = AVPlayer(url: dashPreviewUrl)
                item = previewAV.currentItem
            }
            
            guard let item else { return }
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
        if isPlaying {
            self.avPlayer?.play()
        } else {
            self.avPlayer?.pause()
        }
    }
    
    public func skip(seconds: Double) {
        guard let player = self.avPlayer, let duration = player.currentItem?.duration else {
            return
        }
        
        let currentTime = player.currentTime().seconds
        let newTime = max(0, min(duration.seconds, currentTime + seconds))
        
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
