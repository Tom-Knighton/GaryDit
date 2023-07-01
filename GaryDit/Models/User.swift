//
//  User.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation

public struct User: Codable {
    
    let id: String
    let isEmployee: Bool
    let over18: Bool
    let iconImg: String
    let linkKarma: Int
    let totalKarma: Int
    let name: String
    let createdUtc: Double
    
    public func getDateTimeCreated() -> Date {
        return Date(timeIntervalSince1970: createdUtc)
    }
}
