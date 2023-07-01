//
//  SubredditService.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation

public struct SubredditService {
    
    public static let apiClient = APIClient()
    
    public static func GetPosts(for subredditName: String) async throws -> [RedditPost] {
        let request = APIRequest(path: "r/\(subredditName)", queryItems: [], body: nil)
        let result: SubredditPostResponse = try! await apiClient.perform(request)
        
        print(result)
        return result.data.children.compactMap({ $0.data })
    }
}
