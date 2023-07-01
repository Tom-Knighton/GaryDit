//
//  Token.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation

public struct AuthToken: Codable {
    
    public let Token: String
    public let RefreshToken: String
    public let ExpiryDate: Date
    
    public func IsValid() -> Bool {
        return ExpiryDate > Date()
    }
    
    public static func buildFromOauthResponse(_ oauth: OAuthResponse) -> AuthToken {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .second, value: 59, to: Date()) ?? Date()
        
        var newToken: AuthToken = AuthToken(Token: oauth.accessToken, RefreshToken: oauth.refreshToken, ExpiryDate: date)
        return newToken
    }
}
