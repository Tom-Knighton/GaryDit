//
//  RedditPostViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 19/06/2023.
//

import SwiftUI
import Observation
import LinkPresentation

enum PostBylineDisplayBehaviour {
    case showSubreddit
    case showUsername
}

@MainActor
public class RedditPostViewModel: ObservableObject {
    
    @Published var post: Post
    
    init(post: Post) {
        self.post = post
    }
}
