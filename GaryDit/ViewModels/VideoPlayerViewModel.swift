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
public class VideoPlayerViewModel {
    
    public var media: PostMedia
    public var currentProgress: Double = 0
    public var isPlaying: Bool = false
    public var thumbnailFrames: [UIImage] = []
    public var isScrubbing: Bool = false
    public var mediaDuration: Double = 0
    public var mediaHasAudio: Bool = false

    
    public var mediaIsMuted: Bool {
        return _internalAVIsMuted
    }
    
    public var mediaTimePlayed: Double {
        return currentTime
    }
    
    public var mediaTimeLeft: Double {
        return Double(max(0, (Int(self.avPlayer?.currentItem?.duration.seconds ?? 0)) - Int(mediaTimePlayed)))
    }

    public var avPlayer: AVPlayer?
    
    private var timeObserver: Any?
    private var pauseCancellable: AnyCancellable?
    private var hasTriedThumbnails = false
    private var currentTime: Double = 0
    private var notificationCancellable: Cancellable?
    private var _mutedCancellable: Cancellable?
    private var _internalAVIsMuted: Bool = true
    
    init(media: PostMedia) {
        self.media = media
        
        notificationCancellable = NotificationCenter.default
            .publisher(for: .AllPlayersStopAudio)
            .sink() { [weak self] output in
                
                if let excluding = output.userInfo?["excludingUrl"] as? String, excluding == media.url {
                    return
                }
                
                self?.avPlayer?.isMuted = true
            }
    }
    
    deinit {
        self.notificationCancellable?.cancel()
        self.pauseCancellable?.cancel()
        self._mutedCancellable?.cancel()
        if let avPlayer, let timeObserver {
            avPlayer.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
    
    public func setAvPlayer(_ to: AVPlayer) {
        self.avPlayer = to
        
        if let _ = timeObserver {
            self.timeObserver = nil
        }
        
        self.pauseCancellable?.cancel()
        self._mutedCancellable?.cancel()
        
        self.timeObserver = self.avPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 1000), queue: .main, using: { [weak self] time in
            guard self?.avPlayer?.currentItem?.status == .readyToPlay else {
                return
            }
            
            if self?.hasTriedThumbnails == false {
                self?.hasTriedThumbnails = true
                self?.generateThumbnails()
                self?.mediaDuration = self?.avPlayer?.currentItem?.duration.seconds ?? 0
                Task { [weak self] in
                    let audioGroup = try? await self?.avPlayer?.currentItem?.asset.loadMediaSelectionGroup(for: .audible)
                    self?.mediaHasAudio = audioGroup?.options.compactMap { $0.mediaType }.contains(.audio) == true
                }
            }
            
            self?.currentTime = time.seconds
            self?.currentProgress = time.seconds / (self?.avPlayer?.totalDuration ?? 0)
        })
        
        self.pauseCancellable = self.avPlayer?.publisher(for: \.timeControlStatus)
            .sink { [unowned self] status in
                self.isPlaying = status == .playing
            }
        
        self._mutedCancellable = self.avPlayer?.publisher(for: \.isMuted)
            .sink { [unowned self] isMuted in
                self._internalAVIsMuted = isMuted
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
        
        HapticService.start(.soft)
    }
    
    public func skip(seconds: Double) {
        guard let player = self.avPlayer, let duration = player.currentItem?.duration else {
            return
        }
        
        let currentTime = player.currentTime().seconds
        let newTime = max(0, min(duration.seconds, currentTime + seconds))
        
        player.seek(to: CMTime(seconds: newTime, preferredTimescale: 1000), toleranceBefore: .zero, toleranceAfter: .zero)
        HapticService.start(.soft)
    }
    
    public func toggleMute() {
        self.avPlayer?.isMuted.toggle()
        HapticService.start(.soft)
    }
}
