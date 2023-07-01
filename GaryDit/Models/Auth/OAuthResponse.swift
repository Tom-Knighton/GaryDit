//
//  OAuthResponse.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation

public struct OAuthResponse: Codable {
    
    public let accessToken: String
    public let refreshToken: String
}
