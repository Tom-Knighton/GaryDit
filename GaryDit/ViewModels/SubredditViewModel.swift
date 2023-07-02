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
    var posts: [RedditPost] = []
    var isLoading: Bool = false
    var noMorePosts: Bool = false
    
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
        return !self.isLoading && !self.noMorePosts && self.posts.suffix(3).compactMap { $0.id }.contains(postId)
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
            
            let existingIds = self.posts.compactMap { $0.id }
            self.posts.append(contentsOf: newPosts.filter { existingIds.contains($0.id) == false })
        } catch is CancellationError {
            //...
        } catch {
            guard !Task.isCancelled else {
                return
            }
            
            fatalError(error.localizedDescription)
        }
    }
    
}
