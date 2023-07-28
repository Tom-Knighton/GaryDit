//
//  VideoView.swift
//  GaryDit
//
//  Created by Tom Knighton on 21/06/2023.
//

import Foundation
import SwiftUI
import AVFoundation

protocol VideoViewDelegate {
    func updateAvPlayer(_ av: AVPlayer)
}

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
    var vm: VideoPlayerViewModel
    
    var delegate: VideoViewDelegate?
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var avPlayer: AVPlayer? {
        get {
            return vm.avPlayer
        }
    }
    
    init(viewModel: VideoPlayerViewModel, gravity: PlayerViewGravity = .fit, isPlaying: Bool = false) {
        self.vm = viewModel
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
        Task.detached(priority: .userInitiated) {
            guard let url = await URL(string: self.vm.media.url) else {
                throw URLError(.badURL)
            }
            
            if let player = await self.vm.avPlayer {
                try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [])
                await self.layoutAVPlayer(player: player, gravity: gravity)
                return
            }
            
            let asset = AVAsset(url: url)
            let _ = try await asset.load(.tracks, .duration, .isPlayable)
            
            let composition = AVPlayerItem(asset: asset)
            
            let player = AVPlayer(playerItem: composition)
            player.isMuted = true
            
            try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [])
            
            await self.delegate?.updateAvPlayer(player)
            await self.layoutAVPlayer(player: player, gravity: gravity)
        }
    }
    
    func layoutAVPlayer(player: AVPlayer, gravity: PlayerViewGravity) async {
        await MainActor.run {
            self.playerLayer.player = player
            self.playerLayer.videoGravity = gravity.avGravity
            self.frame = self.playerLayer.visibleRect
            
            if (self.isPlaying) {
                self.playerLayer.player?.play()
            }
            
            _ = NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: self.avPlayer?.currentItem, queue: nil) { [weak self] _ in
                self?.avPlayer?.seek(to: CMTime.zero)
                self?.avPlayer?.play()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        self.frame = playerLayer.visibleRect
    }
}

struct PlayerView: UIViewRepresentable {
    
    var viewModel: VideoPlayerViewModel
    @Binding var isPlaying: Bool
    
    class Coordinator: VideoViewDelegate {
        
        private var viewModel: VideoPlayerViewModel
        
        init(_ vm: VideoPlayerViewModel) {
            self.viewModel = vm
        }
        
        func updateAvPlayer(_ av: AVPlayer) {
            viewModel.setAvPlayer(av)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel)
    }
    
    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView(viewModel: self.viewModel, gravity: .fit, isPlaying: isPlaying)
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if isPlaying {
            uiView.isPlaying = true
            viewModel.avPlayer?.play()
        } else {
            uiView.isPlaying = false
            viewModel.avPlayer?.pause()
        }
    }
}
