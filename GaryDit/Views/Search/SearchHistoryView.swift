//
//  SearchHistoryView.swift
//  GaryDit
//
//  Created by Tom Knighton on 31/08/2023.
//

import Foundation
import SwiftUI
fileprivate let defaultAvatar: String = "profile_avatar_basic"

public struct SearchHistoryView: View {
    
    @Environment(GlobalStoreViewModel.self) private var globalVM
    
    public let history: SearchHistoryModel
    
    public var body: some View {
        HStack {
            if !history.imageUrl.isEmpty {
                CachedImageView(url: history.imageUrl)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 3)
                    .clipShape(.circle)
            } else {
                switch history.type {
                case .user:
                    Image(defaultAvatar)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .clipShape(.circle)
                case .subreddit:
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .overlay {
                            Text("r/")
                                .bold()
                                .shadow(radius: 3)
                        }
                case .trendSubreddit:
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                case .randSubreddit:
                    Image(systemName: "arrow.triangle.2.circlepath.circle")
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                case .searchQuery:
                    Image(systemName: "magnifyingglass.circle")
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                }
            }
            
            Text(history.name)
            Spacer()
        }
        .padding(.all, 6)
        .background(Color.layer2)
        .clipShape(.rect(cornerRadius: 10))
    }
}
