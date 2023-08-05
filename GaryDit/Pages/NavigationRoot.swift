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
//                Task {
//                    self.globalVM.postListPath.append(Post(postId: "1", postAuthour: "Banging_Bananas", postSubreddit: "UkPolitics", postTitle: "Daily Megathread", postScore: 100, postScorePercentage: 100, postCreatedAt: Date(), postEditedAt: nil, postCommentCount: 100, postFlagDetails: PostFlags(isNSFW: false, isSaved: false, isLocked: false, isStickied: true, isArchived: false, isSpoiler: false, distinguishmentType: .none), postContent: PostContent(contentType: .textOnly, textContent: "---\r\n\r\n**[👋](https://i.imgur.com/h5wkqf4.png) Welcome to /r/ukpolitics' daily megathreads, for light real-time discussion of the day's latest developments.**\r\n\r\n---\r\n\r\n\r\nPlease do not submit articles to the megathread which clearly stand as their own submission. Links as comments are not useful here. Add a headline, tweet content or explainer please.\r\n\r\nThis thread will automatically roll over into a new one at **4,000** comments, and at 06:00 GMT each morning.\r\n\r\nYou can join **[our Discord server](https://discord.gg/DPQERCvzbg)** for real-time discussion with fellow subreddit users, and **[follow our Twitter account](https://twitter.com/rukpoliticsmods)** to keep up with the latest developments.\r\n\r\n---\r\n\r\n###Useful Links\r\n\r\n**** · [**🌎 International Politics Discussion Thread**](https://www.reddit.com/r/ukpolitics/comments/14peq9l/international_politics_discussion_thread/?sort=new)\r\n\r\n[**📺 Daily Parliament Guide**](https://parliamentlive.tv/Guide) . [**📜 Commons**](https://parliamentlive.tv/Commons) . [**📜 Lords**](https://parliamentlive.tv/Lords) . [**📜 Committees**](https://parliamentlive.tv/Committees)\r\n\r\n[**📋 Spring 2023 Subreddit Survey by /u/lets_chill_dude**](https://old.reddit.com/r/ukpolitics/comments/13fqgjf/rukpolitics_spring_23_survey/)\r\n\r\n---", media: [])))
//                }
            }
            
            HomePage()
                .tag(1)
                .tabItem { Label("Account", systemImage: "person.fill") }
        })
    }
}
