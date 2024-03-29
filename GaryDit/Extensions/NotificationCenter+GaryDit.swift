//
//  NotificationCenter+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 16/07/2023.
//

import Foundation

extension Notification.Name {
    
    static let AllPlayersStopAudio = Notification.Name("AllPlayersStopAudio")
    static let MediaGalleryFullscreenPresented = Notification.Name("MediaGalleryFullscreenPresented")
    static let MediaGalleryFullscreenDismissed = Notification.Name("MediaGalleryFullscreenDismissed")
    
    static let ObjectVotedOn = Notification.Name("RedditObjectVotedOn")
}
