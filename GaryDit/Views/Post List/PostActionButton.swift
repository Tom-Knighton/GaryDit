//
//  PostActionButton.swift
//  GaryDit
//
//  Created by Tom Knighton on 06/08/2023.
//

import Foundation
import SwiftUI

struct PostActionButton: View {
    
    let label: String?
    let systemIcon: String
    let tintColor: Color
    let isActive: Bool
    
    init(systemIcon: String, label: String? = nil, tintColor: Color = .accentColor, isActive: Bool = false) {
        self.systemIcon = systemIcon
        self.label = label
        self.tintColor = tintColor
        self.isActive = isActive
    }
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 4) {
                Image(systemName: systemIcon)
                if let label {
                    Text(label)
                }
            }
            .foregroundStyle(isActive ? tintColor : .gray)
            .tint(isActive ? tintColor : .gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background {
                if isActive {
                    (isActive ? tintColor : .gray).opacity(0.1)
                        .clipShape(.capsule)
                }
            }
            .overlay {
                Capsule()
                    .stroke(isActive ? tintColor : .gray, lineWidth: 1)
            }
            .transition(.opacity)
        }
    }
}
