//
//  DistinguishmentType.swift
//  GaryDit
//
//  Created by Tom Knighton on 09/07/2023.
//

import Foundation

public enum DistinguishmentType: String, Codable {
    case moderator = "moderator"
    case admin = "admin"
    case special = "special"
    case none = "none"
}
