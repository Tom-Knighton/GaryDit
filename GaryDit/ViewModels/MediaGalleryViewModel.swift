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
    
    init(initialTabUrl: String) {
        self.selectedTabUrl = initialTabUrl
    }
    
    @ObservationIgnored
    public var doubleTapZoomGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation(.easeInOut(duration: 1)) {
                self.currentZoomScale = self.currentZoomScale == 1 ? self.maxZoomScale / 2 : 1
            }
        }
    }
}
