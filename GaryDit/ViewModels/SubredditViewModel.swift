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
    var filteredPosts: [Post] = []
    var isLoading: Bool = false
    var noMorePosts: Bool = false
    
    var searchQuery: String = ""
    
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
        let lastPosts = self.filteredPosts.isEmpty == true ? self.posts.suffix(3) : self.filteredPosts.suffix(3)
        return !self.isLoading && !self.noMorePosts && lastPosts.compactMap { $0.postId }.contains(postId)
    }
    
    func fetchPosts(after: String? = nil) async {
        guard !subredditName.isEmpty, !self.isLoading else {
            return
        }
        
        logger.debug("Fetching posts...")
        
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            
            if filteredPosts.isEmpty == false {
                let last = self.filteredPosts.last?.postId
                let results = try? await SearchService.searchPosts(query: self.searchQuery, subreddit: self.subredditName, limit: 25, afterPost: last)
                let existingIds = self.filteredPosts.compactMap { $0.postId }
                if let results {
                    self.filteredPosts.append(contentsOf: results.filter { existingIds.contains($0.postId) == false })
                }
                return
            }
            
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
    
    func search(locally: Bool) async {
        guard !self.isLoading else {
            return
        }
        
        guard self.searchQuery.isEmpty == false else {
            self.filteredPosts.removeAll()
            return
        }
        
        
        if locally {
            await MainActor.run {
                self.filteredPosts = self.posts.filter { $0.postTitle.contains(self.searchQuery) }
            }
            return
        }
        
        self.isLoading = true
        let results = try? await SearchService.searchPosts(query: self.searchQuery, subreddit: self.subredditName, limit: 25, afterPost: nil)
        if let results {
            await MainActor.run {
                self.filteredPosts = results
                self.isLoading = false
            }
        }
    }
    
    func fetchMorePosts() async {
        let allPostNextId = self.posts.last?.postId
        let nextPostId = self.filteredPosts.isEmpty ? self.filteredPosts.last?.postId ?? allPostNextId : allPostNextId
        await fetchPosts(after: nextPostId)
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
