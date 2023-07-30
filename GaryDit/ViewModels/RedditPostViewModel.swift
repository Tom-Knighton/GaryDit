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

@Observable
public class RedditPostViewModel {
    
    public var post: Post
    
    public var videoViewModels: [VideoPlayerViewModel] = []
    public var overrideVideosDontStopWhenDisappear: Bool = false
    public var displayMediaBelowTitle: Bool {
        if post.postContent.contentType == .linkOnly {
            return true
        }
        
        return false
    }
    
    init(post: Post) {
        self.post = post
        self.setupMediaViewModels()
    }
    
    public func setupMediaViewModels(withExistingVM: VideoPlayerViewModel? = nil) {
        let mediaToCreateFor = post.postContent.media.filter { $0.type == .video }
        for media in mediaToCreateFor {
            if let vm = withExistingVM, media.url == vm.media.url {
                videoViewModels.append(vm)
            } else {
                videoViewModels.append(VideoPlayerViewModel(media: media))
            }
        }
    }
    
    public func getMediaModelForUrl(_ url: String) -> VideoPlayerViewModel? {
        if let vm = self.videoViewModels.first(where: { $0.media.url == url }) {
            return vm
        }
        
        return nil
    }
}

extension RedditPostViewModel: Hashable {
    
    public static func == (lhs: RedditPostViewModel, rhs: RedditPostViewModel) -> Bool {
        return lhs.post.postId == rhs.post.postId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(post)
    }
}
