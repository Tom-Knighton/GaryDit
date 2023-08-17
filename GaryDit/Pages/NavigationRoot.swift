//
//  NavigationRoot.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation
import SwiftUI

public struct NavigationRootPage: View {
    
    @EnvironmentObject private var globalVM: GlobalStoreViewModel
    @State private var tabSelection: Int = 0
    
    public var body: some View {
        
        TabView(selection: $tabSelection, content: {
            
            NavigationStack(path: $globalVM.postListPath) {
                PostListPage()
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
            .tag(0)
            .tabItem{ Label("Posts", systemImage: "lightswitch.on.fill") }
            
            NavigationStack(path: $globalVM.searchPath) {
                SearchPage()
            }
            .tag(1)
            .tabItem { Label("Search", systemImage: "magnifyingglass.circle.fill")}
            
            HomePage()
                .tag(2)
                .tabItem { Label("Account", systemImage: "person.fill") }
        })
    }
}
