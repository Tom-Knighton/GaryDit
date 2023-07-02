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
    
    init(post: RedditPost) {
        self.post = post
    }
    
    func getPostType() -> RedditPostHint {
        return self.post.postHint ?? .SelfPost
    }
}
