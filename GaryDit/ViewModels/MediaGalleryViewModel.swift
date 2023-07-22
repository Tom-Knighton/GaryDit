//
//  MediaGalleryViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 22/07/2023.
//

import Foundation
import Observation
import UIKit
import SwiftUI

@Observable
public class MediaGalleryViewModel {
    
    //MARK: Controls
    public var displayControls: Bool = true
    public var controlTimeoutTask: DispatchWorkItem?

    //MARK: Scrubbing
    public var isScrubbing: Bool = false
    public var scrubOffset: CGSize = .zero
    public var scrubProgress: Double = 0
    public var wasMediaPlayingBeforeScrub: Bool = false
    public var scrubThumbnail: UIImage?
    
    //MARK: Zoom
    public var currentZoomScale: CGFloat = 1
    public let maxZoomScale: CGFloat = 10
    
    //MARK: Opacity
    public var backgroundOpacity: Double = 1
    public var entireViewOpacity: Double = 1
    
    //MARK: Tab view
    public var selectedTabUrl: String
    
    //MARK: Private
    
    init(initialTabUrl: String) {
        self.selectedTabUrl = initialTabUrl
    }
    
    @ObservationIgnored
    public var doubleTapZoomGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation(.easeInOut(duration: 1)) {
                self.currentZoomScale = self.currentZoomScale == 1 ? 5 : 1
            }
        }
    }
    
    func timeoutControls() {
        if let controlTimeoutTask {
            controlTimeoutTask.cancel()
        }
        
        controlTimeoutTask = DispatchWorkItem(block: { [weak self] in
            guard self?.isScrubbing == false else {
                self?.timeoutControls()
                return
            }
            
            withAnimation(.easeInOut(duration: 0.5)) {
                self?.displayControls = false
            }
        })
        
        if let controlTimeoutTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: controlTimeoutTask)
        }
    }
}
