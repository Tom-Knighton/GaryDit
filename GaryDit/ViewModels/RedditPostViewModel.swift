//
//  RedditPostViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 19/06/2023.
//

import SwiftUI
import Observation
import LinkPresentation

@MainActor
public class RedditPostViewModel: ObservableObject {
    
    @Published var post: RedditPost
    @Published var linkMetadata: LPLinkMetadata? = nil
    
    init(post: RedditPost) {
        self.post = post
        Task {
            await self.setupData()
        }
    }
    
    func getPostType() -> RedditPostHint {
        return self.post.postHint ?? .SelfPost
    }
    
    private func setupData() async {
        if self.post.postHint == RedditPostHint.Link {
            if let url = URL(string: self.post.url ?? ""),
               let metadata = await url.getMetadata() {
                self.linkMetadata = metadata
            }
        }
    }
    
}
