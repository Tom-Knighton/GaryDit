//
//  HapticService.swift
//  GaryDit
//
//  Created by Tom Knighton on 16/07/2023.
//

import UIKit

struct HapticService {
    
    static func start(_ hapticLevel: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: hapticLevel)
        generator.impactOccurred()
    }
}
