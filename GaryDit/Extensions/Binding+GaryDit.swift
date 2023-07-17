//
//  Binding+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 14/07/2023.
//

import Foundation
import SwiftUI

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
