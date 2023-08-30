//
//  View+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 29/08/2023.
//

import Foundation
import SwiftUI
import Combine

extension View {
    
    public func onReceive<Value>(of value: Value, debounceTime: TimeInterval, perform action: @escaping (_ newValue: Value) -> Void) -> some View where Value: Equatable {
        self.modifier(DebouncedChangeViewModifier(trigger: value, debounceTime: debounceTime, action: action))
    }
}

private struct DebouncedChangeViewModifier<Value>: ViewModifier where Value: Equatable {
    let trigger: Value
    let debounceTime: TimeInterval
    let action: (Value) -> Void

    @State private var debouncedTask: Task<Void,Never>?

    func body(content: Content) -> some View {
        content.onChange(of: trigger, initial: false) { _, value in
            debouncedTask?.cancel()
            debouncedTask = Task.delayed(seconds: debounceTime) { @MainActor in
                action(value)
            }
        }
    }
}

