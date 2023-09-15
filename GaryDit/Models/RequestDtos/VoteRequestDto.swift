//
//  VoteRequestDto.swift
//  GaryDit
//
//  Created by Tom Knighton on 14/09/2023.
//

import Foundation

struct VoteRequestDto: Codable {
    public let objectId: String
    public let voteStatus: VoteStatus
}
