//
//  PostContinuedViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 12/08/2023.
//

import Foundation
import Observation

@Observable
public class PostContinuedViewModel {
    
    public var post: Post
    public var rootCommentId: String
    
    public init(post: Post, rootId: String) {
        self.post = post
        self.rootCommentId = rootId
    }
}

extension PostContinuedViewModel: Hashable {
    public static func == (lhs: PostContinuedViewModel, rhs: PostContinuedViewModel) -> Bool {
        return lhs.post.postId == rhs.post.postId
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(post)
    }
}
