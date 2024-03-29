//
//  SubredditService.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation

public struct SubredditService {
    
    public static let apiClient = APIClient()
    
    public static func GetPosts(for subredditName: String, after: String? = nil, sortMethod: RedditSort = .hot) async throws -> [Post] {
        var queryItems: [URLQueryItem] = []
        if let after {
            queryItems += [URLQueryItem(name: "after", value: after)]
        }
        queryItems += [URLQueryItem(name: "sortMethod", value: sortMethod.rawValue)]
        let request = APIRequest(path: "subreddit/\(subredditName)/posts", queryItems: queryItems, body: nil)
        let result: [Post] = try await apiClient.perform(request)
        return result
    }
    
    public static func GetTrendingSubreddits() async throws -> [String] {
        
        let request = APIRequest(path: "subreddit/DailyTrending", queryItems: [], body: nil)
        let result: [String] = try await apiClient.perform(request)
        return result
    }
    
    public static func GetRandomSubreddit(nsfw: Bool = false) async throws -> String {
        var queryItems: [URLQueryItem] = []
        queryItems += [URLQueryItem(name: "nsfw", value: "\(nsfw)")]

        
        let request = APIRequest(path: "subreddit/random", queryItems: queryItems, body: nil)
        let result: String = try await apiClient.perform(request)
        return result
    }
}
