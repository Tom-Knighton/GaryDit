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
            
            NavigationStack(path: $globalVM.PostPageNavPath) {
                PostsPage()
                    .navigationDestination(for: Post.self) { post in
                        PostPage(post: post)
                    }
                    .onAppear {
                        Task {
                            //TODO: Remove
                            globalVM.PostPageNavPath.append(Post(postId: "1", postAuthour: "Test", postSubreddit: "Test", postTitle: "Test", postScore: 1, postCreatedAt: Date(), postEditedAt: nil, postFlagDetails: PostFlags(isNSFW: true, isSaved: true, isLocked: true, isStickied: true, isArchived: true, distinguishmentType: .none), postContent: PostContent(contentType: .textOnly, textContent: "Here", media: [])))                        //                            self.mapNavigator.push(OfflineTimetableNavLink(name: "Stratford", stopPointId: "HUBSRA", lineId: "central"))
                        }
                    }
            }
            .tag(0)
            .tabItem{ Label("Posts", systemImage: "lightswitch.on.fill") }
            
            HomePage()
                .tag(1)
                .tabItem { Label("Account", systemImage: "person.fill") }
        })
    }
}
