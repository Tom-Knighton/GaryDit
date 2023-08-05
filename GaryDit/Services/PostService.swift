//
//  PostService.swift
//  GaryDit
//
//  Created by Tom Knighton on 04/08/2023.
//

import Foundation

public struct PostService {
    
    public static let apiClient = APIClient()
    
    public static func GetPostDetails(for postId: String) async throws -> Post {
        
        let request = APIRequest(path: "post/\(postId)/details", queryItems: [], body: nil)
        let result: Post = try await apiClient.perform(request)
        return result
    }
    
    public static func GetPostComments(for postId: String) async throws -> [PostComment] {
        let request = APIRequest(path: "post/\(postId)/comments", queryItems: [], body: nil)
        let result: [PostComment] = try await apiClient.perform(request)
        return result
    }
}
