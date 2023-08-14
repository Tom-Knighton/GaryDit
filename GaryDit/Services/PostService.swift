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
    
    public static func GetPostComments(for postId: String, rootId: String? = nil) async throws -> [PostComment] {
        var queryItems: [URLQueryItem] = []
        if let rootId {
            queryItems.append(URLQueryItem(name: "startFrom", value: rootId))
        }
        let request = APIRequest(path: "post/\(postId)/comments", queryItems: queryItems, body: nil)
        let result: [PostComment] = try await apiClient.perform(request)
        return result
    }
    
    public static func GetMoreComments(for postId: String, replacingId: String, childIds: [String]) async throws -> MoreCommentsDto {
        let childIdString = childIds.joined(separator: ",")
        let request = APIRequest(path: "post/\(postId)/comments/\(replacingId)/more", queryItems: [URLQueryItem(name: "childIds", value: childIdString)], body: nil)
        let result: MoreCommentsDto = try await apiClient.perform(request)
        return result
    }
}
