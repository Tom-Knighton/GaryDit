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
    var filteredPosts: [Post]? = nil
    var isLoading: Bool = false
    var noMorePosts: Bool = false
    
    var searchQuery: String = ""
    var wasFromSearch: Bool = false
    
    var sortMethod: RedditSort = .hot
    
    var bylineDisplayBehaviour: PostBylineDisplayBehaviour {
        let formattedName = self.subredditName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let blockList = ["all", "home", "popular"]
        let isMultireddit = formattedName.contains("+")
        let subredditIsBlocked = blockList.contains(formattedName)
        
        let shouldShowUsernames = !subredditIsBlocked && !isMultireddit
        
        return shouldShowUsernames ? .showUsername : .showSubreddit
    }
    
    var postsToDisplay: [Post] {
        if let filtered = self.filteredPosts {
            return filtered
        }
        
        return posts
    }

    @ObservationIgnored
    var logger = Logger(category: "SubredditViewModel")
    
    init(subredditName: String) {
        self.subredditName = subredditName
    }
    
    init(subredditName: String, searchQuery: String) {
        self.subredditName = subredditName
        self.wasFromSearch = true
        self.setSubredditName(to: subredditName, fetchPostsAutomatically: false)
        Task.detached {
            self.searchQuery = searchQuery
            await self.search(locally: false)
        }
    }
    
    func setSubredditName(to subredditName: String, fetchPostsAutomatically: Bool = true) {
        self.subredditName = subredditName
        
        if fetchPostsAutomatically {
            fetchPosts()
        }
    }

    @MainActor
    func shouldFetchMore(from postId: String) -> Bool {
        let lastPosts = self.postsToDisplay.suffix(3)
        let shouldFetchMore = !self.isLoading && !self.noMorePosts && lastPosts.compactMap { $0.postId }.contains(postId)
        if shouldFetchMore {
            print("true!!!")
        }
        return shouldFetchMore
    }
    
    func fetchPosts(nextPage: Bool = false) {
        
        guard !subredditName.isEmpty, !self.isLoading else {
            return
        }
        
        self.isLoading = true

        logger.debug("Fetching posts...")
        
        Task {
            do {
                if let _ = filteredPosts {
                    let last = self.filteredPosts?.last?.postId
                    let results = try? await SearchService.searchPosts(query: self.searchQuery, subreddit: self.subredditName, limit: 25, afterPost: nextPage ? last : nil)
                    let existingIds = self.filteredPosts?.compactMap { $0.postId }
                    if let results {
                        await MainActor.run {
                            self.filteredPosts?.append(contentsOf: results.filter { existingIds?.contains($0.postId) == false })
                            self.isLoading = false
                        }
                    }
                    return
                }
                
                let last = self.posts.last?.postId
                let newPosts = try await SubredditService.GetPosts(for: subredditName, after: nextPage ? last : nil)
                let existingIds = self.posts.compactMap { $0.postId }
                let newToAdd = newPosts.filter { existingIds.contains($0.postId) == false }
                if newToAdd.isEmpty {
                    self.noMorePosts = true
                    self.isLoading = false
                    return
                }
                
                await MainActor.run {
                    self.posts.append(contentsOf: newToAdd)
                    self.isLoading = false
                }
                
            } catch is CancellationError {
                print("cancelled")
                self.isLoading = false
                //...
            } catch {
                guard !Task.isCancelled else {
                    print("cancelled")
                    self.isLoading = false
                    return
                }
                
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func search(locally: Bool) async {
        guard !self.isLoading else {
            return
        }
        
        guard self.searchQuery.isEmpty == false else {
            self.filteredPosts = nil
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
        } else {
            print("no results?")
        }
    }
    
    func resetAndFetchPosts() async {
        guard !subredditName.isEmpty, !self.isLoading else {
            return
        }
        
        self.posts.removeAll()
        self.fetchPosts()
    }    
    
    func changeSortMethod(to method: RedditSort) {
        self.sortMethod = method
        
        Task {
            if self.searchQuery.isEmpty == false {
                let posts = try? await SearchService.searchPosts(query: self.searchQuery, subreddit: self.subredditName, sortMethod: self.sortMethod)
                await MainActor.run {
                    self.filteredPosts = posts
                }
            } else {
                let posts = try? await SubredditService.GetPosts(for: self.subredditName, sortMethod: self.sortMethod)
                if let posts {
                    self.posts = posts
                }
                else {
                    print(":(")
                }
            }
        }
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
