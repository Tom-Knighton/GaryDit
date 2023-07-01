//
//  UserService.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation

public struct UserService {
    
    private static let api = APIClient()
    
    public static func GetMe() async throws -> User {
        let request = APIRequest(path: "api/v1/me", queryItems: [], body: nil)
        let result: User = try await api.perform(request)
        return result
    }
}
