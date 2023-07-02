//
//  SubredditService.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation

public struct SubredditService {
    
    public static let apiClient = APIClient()
    
    public static func GetPosts(for subredditName: String, after: String? = nil) async throws -> [RedditPost] {
        var queryItems: [URLQueryItem] = []
        if let after {
            queryItems += [URLQueryItem(name: "after", value: after)]
        }
        
        let request = APIRequest(path: "r/\(subredditName)", queryItems: queryItems, body: nil)
        let result: SubredditPostResponse = try await apiClient.perform(request)
        return result.data.children.compactMap({ $0.data })
    }
}
