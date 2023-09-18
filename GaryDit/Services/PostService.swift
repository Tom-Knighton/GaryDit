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
        let dto = RequestCommentsDto(childCommentIds: childIds)
        
        let request = APIRequest(method: .post, path: "post/\(postId)/comments/\(replacingId)/more", queryItems: [], body: dto.toJson())
        let result: MoreCommentsDto = try await apiClient.perform(request)
        return result
    }
    
    public static func Vote(on postId: String, _ voteStatus: VoteStatus) async throws {
        
        let request = APIRequest(method: .post, path: "post/\(postId)/vote", queryItems: [], body: VoteRequestDto(objectId: postId, voteStatus: voteStatus).toJson())
        let _: String = try await apiClient.perform(request)
    }
    
    public static func Vote(on postId: String, commentId: String, _ voteStatus: VoteStatus) async throws {
        
        let request = APIRequest(method: .post, path: "post/\(postId)/comment/\(commentId)/vote", queryItems: [], body: VoteRequestDto(objectId: commentId, voteStatus: voteStatus).toJson())
        let _: String = try await apiClient.perform(request)
    }
    
    public static func ToggleSave(postId: String, _ save: Bool) async throws {
        let request = APIRequest(method: .put, path: "post/\(postId)/\(save ? "save" : "unsave")", queryItems: [], body: nil)
        let _: String = try await apiClient.perform(request)
    }
    
    public static func ToggleSave(postId: String, commentId: String, _ save: Bool) async throws {
        let request = APIRequest(method: .put, path: "post/\(postId)/comment/\(commentId)/\(save ? "save" : "unsave")", queryItems: [], body: nil)
        let _: String = try await apiClient.perform(request)
    }
}
