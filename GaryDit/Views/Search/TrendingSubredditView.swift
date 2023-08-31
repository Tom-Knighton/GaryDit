//
//  TrendingSubredditView.swift
//  GaryDit
//
//  Created by Tom Knighton on 31/08/2023.
//

import Foundation
import SwiftUI

public struct TrendingSubredditView: View {
    
    public let subredditName: String
    
    public var body: some View {
        HStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundStyle(.blue)
                .frame(width: 30, height: 30)
            Text(subredditName)
            Spacer()
        }
        .padding(.all, 6)
        .background(Color.layer2)
        .clipShape(.rect(cornerRadius: 10))
    }
}
