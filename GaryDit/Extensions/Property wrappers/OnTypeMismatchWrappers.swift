//
//  OnTypeMismatchWrappers.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation

@propertyWrapper
struct NilOnTypeMismatch<Value> {
    var wrappedValue: Value?
}

extension NilOnTypeMismatch: Codable where Value: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.wrappedValue = try? container.decode(Value.self)
    }
}
