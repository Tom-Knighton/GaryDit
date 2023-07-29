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
            }
            .tag(0)
            .tabItem{ Label("Posts", systemImage: "lightswitch.on.fill") }
            .onAppear {
                Task {
                    self.globalVM.postListPath.append(Post(postId: "1", postAuthour: "Banging_bananas", postSubreddit: "GaryDitTesting", postTitle: "I carved the scariest pumpkin I could imagine ", postScore: 100, postCreatedAt: Date(), postEditedAt: Date(), postFlagDetails: PostFlags(isNSFW: false, isSaved: false, isLocked: false, isStickied: false, isArchived: false, distinguishmentType: .none), postContent: PostContent(contentType: .textOnly, textContent: "Very scary I got spooked :( >!It was so scary!<\n\n>!I have no friends, to trust to be kind. Except for the ones who live in my mind. I can see them, when I'm in my dreams. But now when I sleep, it's torn at the seams. I push it away, but it came too fast. Can't tell what it is, but that it's the past.!< Why are you making me face all my fears? Why again now after all of these years? My heart is broken by that judging eye. It forces me now to confront my own lie. My name may be Sunny, despite all the rain. Now I can see through the grief and the pain. The dream's no escape, instead it's a cage. Now I am ready to turn a new page. https://tomk.online", media: [])))
                }
            }
            
            HomePage()
                .tag(1)
                .tabItem { Label("Account", systemImage: "person.fill") }
        })
    }
}
