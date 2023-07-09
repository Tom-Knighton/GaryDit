//
//  VideoView.swift
//  GaryDit
//
//  Created by Tom Knighton on 21/06/2023.
//

import Foundation
import SwiftUI
import AVFoundation

enum PlayerViewGravity {
    case fit
    case fill
    case stretch
    
    var avGravity: AVLayerVideoGravity {
        switch self {
        case .fit:
            return .resizeAspect
        case .fill:
            return .resizeAspectFill
        case .stretch:
            return .resize
        }
    }
}

class PlayerUIView: UIView {
    
    var isPlaying: Bool = false
    var url: String
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var avPlayer: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    init(url: String, gravity: PlayerViewGravity = .fit, isPlaying: Bool = false) {
        self.url = url
        self.isPlaying = isPlaying
        super.init(frame: .zero)
        
        Task {
            try? await self.setup(gravity: gravity)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(gravity: PlayerViewGravity = .fit) async throws {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        let asset = AVAsset(url: url)
        let _ = try await asset.load(.tracks, .duration, .isPlayable)
        
        let composition = AVPlayerItem(asset: asset)
        let avPlayer = AVPlayer(playerItem: composition)
        avPlayer.isMuted = true
        
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [])
        
        DispatchQueue.main.async {
            self.playerLayer.player = avPlayer
            self.playerLayer.videoGravity = gravity.avGravity
            self.frame = self.playerLayer.visibleRect
            
            if (self.isPlaying) {
                self.playerLayer.player?.play()
            }
            
            _ = NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: self.avPlayer?.currentItem, queue: nil) { [avPlayer] _ in
                avPlayer.seek(to: CMTime.zero)
                avPlayer.play()
            }
        }
    }
    
    func togglePlay(_ to: Bool) {
        self.avPlayer?.seek(to: CMTime.zero)
        to ? self.avPlayer?.play() : self.avPlayer?.pause()
        self.isPlaying = to
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        self.frame = playerLayer.visibleRect
    }
}

struct PlayerView: UIViewRepresentable {
    
    var url: String
    @Binding var isPlaying: Bool
    var gravity: PlayerViewGravity = .fit
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView(url: self.url, gravity: self.gravity, isPlaying: isPlaying)
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if isPlaying != uiView.isPlaying {
            uiView.togglePlay(isPlaying)
        }
    }
}
