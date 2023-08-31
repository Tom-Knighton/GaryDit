//
//  RandomSubredditButton.swift
//  GaryDit
//
//  Created by Tom Knighton on 31/08/2023.
//

import Foundation
import SwiftUI

public struct RandomSubredditButton: View {
    
    public let isNsfw: Bool
    
    public var body: some View {
        HStack {
            Image(systemName: "party.popper")
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)
            Text(isNsfw ? "Random NSFW" : "Random Subreddit")
            Spacer()
        }
        .padding(.all, 6)
        .background(Color.layer2)
        .clipShape(.rect(cornerRadius: 10))
    }
}
