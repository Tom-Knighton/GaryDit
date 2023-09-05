//
//  View+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 29/08/2023.
//

import Foundation
import SwiftUI
import Combine
import SwiftData

extension View {
    
    public func onReceive<Value>(of value: Value, debounceTime: TimeInterval, perform action: @escaping (_ newValue: Value) -> Void) -> some View where Value: Equatable {
        self.modifier(DebouncedChangeViewModifier(trigger: value, debounceTime: debounceTime, action: action))
    }
    
    public func optionalModelContainer(_ container: ModelContainer?) -> some View {
        self.modifier(OptionalModelContainerViewModifier(container: container))
    }
    
    public func addGaryDitNavDestinations() -> some View {
        self
            .navigationDestination(for: SubredditNavModel.self) { nav in
                PostListPage(subreddit: nav.subredditName)
            }
            .navigationDestination(for: SubredditNavSearchQuery.self) { nav in
                PostListPage(nav: nav)
            }
            .navigationDestination(for: Post.self) { post in
                PostPage(post: post)
            }
            .navigationDestination(for: RedditPostViewModel.self) { postVM in
                PostPage(postViewModel: postVM)
            }
            .navigationDestination(for: PostContinuedViewModel.self) { vm in
                PostContinuedPage(viewModel: vm)
            }
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

private struct OptionalModelContainerViewModifier: ViewModifier {
    
    let container: ModelContainer?
    
    func body(content: Content) -> some View {
        if let container {
            content
                .modelContainer(container)
        } else {
            content
        }
    }
}

