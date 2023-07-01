//
//  Codable+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation

extension Encodable {
    
    /// Encodes the model to it's Data representation, useful for sending API requests
    func toJson() -> Data? {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        encoder.dateEncodingStrategy = .formatted(formatter)
        let encoded = try? encoder.encode(self)
        return encoded
    }
}

extension Data {
    func decode<T: Decodable>(to type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(formatter)
        let decoded = try decoder.decode(T.self, from: self)
        return decoded
    }
}
