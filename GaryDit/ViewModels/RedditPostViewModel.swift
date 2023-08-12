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
    
    public var comments: [PostComment] = []
    public var videoViewModels: [VideoPlayerViewModel] = []
    public var overrideVideosDontStopWhenDisappear: Bool = false
    public var isLoadingComments: Bool = false
    
    public var displayMediaBelowTitle: Bool {
        if post.postContent.contentType == .linkOnly {
            return true
        }
        
        return false
    }
    public var hasBeenEdited: Bool {
        return post.postEditedAt != nil
    }
    public var creationOrEditTime: Date {
        return post.postEditedAt ?? post.postCreatedAt
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
    
    public func loadComments() async {
        Task.detached {
            self.isLoadingComments = true
            defer { self.isLoadingComments = false }
            do {
                let comments = try await PostService.GetPostComments(for: self.post.postId)
                self.comments = comments
            } catch {
                print("error getting comments")
            }
        }
    }
    
    public func loadMoreComments(replacingId: String, childIds: [String]) async {
        Task.detached {
            do {
                print(replacingId)
                let newComments = try await PostService.GetMoreComments(for: self.post.postId, replacingId: replacingId, childIds: childIds)
                var updated = self.addMoreComments(in: self.comments, targetId: newComments.moreLinkId, newChildren: newComments.comments)
                await MainActor.run { [updated] in
                    self.comments = updated
                }
            } catch {
                print("erorr adding more comments")
            }
        }
    }
    
    func addMoreComments(in comments: [PostComment], targetId: String, newChildren: [PostComment]) -> [PostComment] {
        return comments.compactMap { comment in
            if comment.commentId == targetId {
                return nil
            }
            
            if let index = comment.replies.firstIndex(where: { $0.commentId == targetId }) {
                var mutableComment = comment
                var updatedReplies = comment.replies
                updatedReplies.remove(at: index)
                updatedReplies.append(contentsOf: newChildren)
                mutableComment.replies = updatedReplies
                return mutableComment
            } else {
                var newReplies = addMoreComments(in: comment.replies, targetId: targetId, newChildren: newChildren)
                var mutableComment = comment
                mutableComment.replies = newReplies
                return mutableComment
            }
        }
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
