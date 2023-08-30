//
//  SubredditViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 01/07/2023.
//

import Foundation
import Observation

@Observable
class SubredditViewModel {
    
    var subredditName: String = ""
    var posts: [Post] = []
    var isLoading: Bool = false
    var noMorePosts: Bool = false
    
    var bylineDisplayBehaviour: PostBylineDisplayBehaviour {
        let formattedName = self.subredditName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let blockList = ["all", "home", "popular"]
        let isMultireddit = formattedName.contains("+")
        let subredditIsBlocked = blockList.contains(formattedName)
        
        let shouldShowUsernames = !subredditIsBlocked && !isMultireddit
        
        return shouldShowUsernames ? .showUsername : .showSubreddit
    }

    @ObservationIgnored
    var logger = Logger(category: "SubredditViewModel")
    
    init(subredditName: String) {
        self.subredditName = subredditName
    }
    
    func setSubredditName(to subredditName: String, fetchPostsAutomatically: Bool = true) {
        self.subredditName = subredditName
        
        if fetchPostsAutomatically {
            Task {
                await fetchPosts()
            }
        }
    }

    @MainActor
    func shouldFetchMore(from postId: String) -> Bool {
        return !self.isLoading && !self.noMorePosts && self.posts.suffix(3).compactMap { $0.postId }.contains(postId)
    }
    
    func fetchPosts(after: String? = nil) async {
        guard !subredditName.isEmpty, !self.isLoading else {
            return
        }
        
        logger.debug("Fetching posts...")
        
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            let newPosts = try await SubredditService.GetPosts(for: subredditName, after: after)
            if newPosts.isEmpty {
                self.noMorePosts = true
                return
            }
            
            let existingIds = self.posts.compactMap { $0.postId }
            self.posts.append(contentsOf: newPosts.filter { existingIds.contains($0.postId) == false })
        } catch is CancellationError {
            //...
        } catch {
            guard !Task.isCancelled else {
                return
            }
            
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchMorePosts() async {
        await fetchPosts(after: self.posts.last?.postId)
    }
    
    func resetAndFetchPosts() async {
        guard !subredditName.isEmpty, !self.isLoading else {
            return
        }
        
        self.posts.removeAll()
        await self.fetchPosts()
    }
    
}

extension SubredditViewModel: Hashable {
    public static func == (lhs: SubredditViewModel, rhs: SubredditViewModel) -> Bool {
        return lhs.subredditName == rhs.subredditName
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(subredditName)
    }
}
