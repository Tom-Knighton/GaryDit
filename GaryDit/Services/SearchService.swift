//
//  SearchService.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/08/2023.
//

import Foundation

public struct SearchService {
    
    
    public static let apiClient = APIClient()
    
    /// Performs a search for subreddits beginning with the search query
    /// - Parameters:
    ///   - query: The text the subreddit's name starts with
    ///   - includeNsfw: Whether or not to include nsfw results (this may not always work, it's up to Reddit's magic/bad api)
    public static func searchSubreddits(query: String, includeNsfw: Bool) async throws -> [SubredditSearchResult] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "searchQuery", value: query))
        queryItems.append(URLQueryItem(name: "includeNsfw", value: "\(includeNsfw)"))
        let request = APIRequest(path: "search/subreddits", queryItems: queryItems, body: nil)
        let result: [SubredditSearchResult] = try await apiClient.perform(request)
        return result
    }
    
    /// Performs a search for users with similar names to the search query
    /// - Parameters:
    ///   - query: The text the subreddit's name starts with
    ///   - includeNsfw: Whether or not to include nsfw results
    ///   - limit: The maximum number of results to display
    public static func searchUsers(query: String, includeNsfw: Bool, limit: Int = 25) async throws -> [UserSearchResult] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "searchQuery", value: query))
        queryItems.append(URLQueryItem(name: "includeNsfw", value: "\(includeNsfw)"))
        queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        let request = APIRequest(path: "search/users", queryItems: queryItems, body: nil)
        let result: [UserSearchResult] = try await apiClient.perform(request)
        return result
    }
    
    
    /// Performs a search against a subreddit, or all subreddits, for posts.
    /// - Parameters:
    ///   - query: The search query to match posts against
    ///   - subreddit: Optionally, a specific subreddit to search, if nil will search all of reddit
    ///   - limit: The max number of posts to return. Max 100
    ///   - afterPost: Optionally, the post id to start results from. Useful for pagination
    ///   - sortMethod: A method to sort posts by
    public static func searchPosts(query: String, subreddit: String? = nil, limit: Int = 25, afterPost: String? = nil, sortMethod: RedditSort = .hot) async throws -> [Post] {
        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "searchQuery", value: query))
        queryItems.append(URLQueryItem(name: "subreddit", value: subreddit))
        queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        queryItems.append(URLQueryItem(name: "after", value: afterPost))
        queryItems.append(URLQueryItem(name: "sortMethod", value: afterPost))
        let request = APIRequest(path: "search", queryItems: queryItems, body: nil)
        let result: [Post] = try await apiClient.perform(request)
        return result
    }
}
