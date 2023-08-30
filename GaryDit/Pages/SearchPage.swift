//
//  SearchPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 15/08/2023.
//

import Foundation
import SwiftUI

public struct SearchPage: View {
    
    @State private var viewModel = SearchPageViewModel()
    
    public var body: some View {
        ZStack {
            Color.layer1.ignoresSafeArea()
            ScrollView {
                VStack {
                    ForEach(viewModel.subredditResults.prefix(5), id: \.subredditName) { subreddit in
                        NavigationLink(value: SubredditNavModel(subredditName: subreddit.subredditName)) {
                            SubredditSearchResultView(subreddit: subreddit)
                                .tint(.primary)
                        }
                    }
                    ForEach(viewModel.userSearchResults, id: \.username) { user in
                        UserSearchResultView(user: user)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 12)

        }
        .navigationTitle("Search")
        .searchable(text: $viewModel.searchQueryText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search subreddits, users, posts...")
        .autocorrectionDisabled()
        .onChange(of: self.viewModel.searchQueryText, { oldValue, newValue in
            // On immediate change of query text
            
            guard self.viewModel.searchQueryText.isEmpty == false else {
                return
            }
            
            self.viewModel.clearUserResults()

        })
        .onReceive(of: self.viewModel.searchQueryText, debounceTime: 0.3) { newValue in
            // After 0.3s of no changes
            Task {
                await self.viewModel.searchForSubreddits()
            }
        }
        .onReceive(of: self.viewModel.searchQueryText, debounceTime: 1) { newValue in
            // After 1s of no changes
            Task {
                await self.viewModel.searchForUser()
            }
        }
    }
}
