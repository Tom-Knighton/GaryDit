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
    
    public var hasLoadedCommentsBefore: Bool = false
    
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
    
    public func loadComments(fromRoot: String? = nil) async {
        Task.detached {
            self.isLoadingComments = true
            defer { self.isLoadingComments = false }
            do {
                let comments = try await PostService.GetPostComments(for: self.post.postId, rootId: fromRoot)
                self.comments = comments
                self.hasLoadedCommentsBefore = fromRoot == nil
            } catch {
                print("error getting comments")
            }
        }
    }
    
    public func loadMoreComments(replacingId: String, parent: String, childIds: [String]) async {
        Task.detached {
            do {
                let newComments = try await PostService.GetMoreComments(for: self.post.postId, replacingId: replacingId, childIds: childIds)
                let updated = self.addMoreComments(in: self.comments, parent: parent, targetId: newComments.moreLinkId, newChildren: newComments.comments)
                await MainActor.run { [updated] in
                    self.comments = updated
                }
            } catch {
                print(error.localizedDescription)
                print("erorr adding more comments")
            }
        }
    }
    
    func addMoreComments(in comments: [PostComment], parent: String, targetId: String, newChildren: [PostComment]) -> [PostComment] {
        
        if parent.starts(with: "t3_") {
            var mutableReplies = comments
            if let index = comments.firstIndex(where: { $0.commentId == targetId }) {
                mutableReplies.remove(at: index)
            }
            return mutableReplies + newChildren
        }
        
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
                let newReplies = addMoreComments(in: comment.replies, parent: parent, targetId: targetId, newChildren: newChildren)
                var mutableComment = comment
                mutableComment.replies = newReplies
                return mutableComment
            }
        }
    }
    
    public func vote(_ status: VoteStatus) {
        Task {
            let currentStatus = post.postVoteStatus
            let newStatus: VoteStatus = currentStatus == status ? .noVote : status
            withAnimation(.spring) {
                post.postVoteStatus = newStatus
            }
            try? await PostService.Vote(on: post.postId, newStatus)
            await MainActor.run {
                NotificationCenter.default.post(name: .ObjectVotedOn, object: nil, userInfo: ["objectId": post.postId, "voteStatus": newStatus])
                HapticService.start(.light)
            }
        }
    }
    
    public func voteOnComment(_ commentId: String, status: VoteStatus) {
        guard let commentIndex = self.comments.firstIndex(where: { $0.commentId == commentId }) else { return }
        let currentStatus = comments[commentIndex].voteStatus
        comments[commentIndex].voteStatus = status
        Task {
            try? await PostService.Vote(on: self.post.postId, commentId: commentId, status)
        }
    }
    
    public func toggleSave() {
        let isSaved = post.postFlagDetails.isSaved
        
        withAnimation(.smooth) {
            post.postFlagDetails.isSaved.toggle()
        }
        
        Task {
            try? await PostService.ToggleSave(postId: post.postId, !isSaved)
        }
    }
    
    func opposite(_ voteStatus: VoteStatus) -> VoteStatus {
        switch voteStatus {
        case .upvoted:
            return .downvoted
        case .downvoted:
            return .upvoted
        case .noVote:
            return .noVote
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
