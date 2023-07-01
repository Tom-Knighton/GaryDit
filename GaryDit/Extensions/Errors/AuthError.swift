//
//  AuthError.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation

enum APIError : Error {
    case missingToken
    case invalidBaseUrl
    case invalidToken
    case couldNotParse
}
