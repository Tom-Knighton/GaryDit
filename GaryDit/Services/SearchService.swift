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
}
