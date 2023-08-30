//
//  SubredditSearchResultView.swift
//  GaryDit
//
//  Created by Tom Knighton on 29/08/2023.
//

import Foundation
import SwiftUI

public struct SubredditSearchResultView: View {
    
    public var subreddit: SubredditSearchResult
    
    public var body: some View {
        VStack {
            HStack {
                if let url = subreddit.subredditImageUrl, !url.isEmpty {
                    CachedImageView(url: url)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .clipShape(.circle)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .overlay {
                            Text("r/")
                                .bold()
                                .shadow(radius: 3)
                        }
                }
                
                Text(subreddit.subredditName)
                Spacer()
            }
            HStack(spacing: 4) {
                Image(systemName: "person.3.fill")
                Text("\(subreddit.subredditSubscriberCount.friendlyFormat()) subscribers")
                Spacer()
                Image(systemName: "dot.circle")
                Text(subreddit.subredditActiveCount.friendlyFormat() + " online")
            }
        }
        .padding(.all, 6)
        .background(Color.layer2)
        .clipShape(.rect(cornerRadius: 10))
        
    }
}
