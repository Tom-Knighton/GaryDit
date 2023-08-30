//
//  SearchPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 15/08/2023.
//

import Foundation
import SwiftUI
import SwiftData

public struct SearchPage: View {
    
    @Environment(GlobalStoreViewModel.self) private var globalVM
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SearchPageViewModel()
    
    @Query(sort: \SearchHistoryModel.accessedAt, order: .reverse) var searchHistory: [SearchHistoryModel]
    
    
    public var body: some View {
        ZStack {
            Color.layer1.ignoresSafeArea()
            ScrollView {
                VStack {
                    ForEach(viewModel.subredditResults.prefix(5), id: \.subredditName) { subreddit in
                        Button(action: { self.cacheRouteAndNavigate(to: subreddit) }) {
                            SubredditSearchResultView(subreddit: subreddit)
                                .tint(.primary)
                        }
                        .accessibilityHint("Navigates to the \(subreddit.subredditName) subreddit")
                    }
                    ForEach(viewModel.userSearchResults, id: \.username) { user in
                        Button(action: { self.cacheRouteAndNavigate(to: user) }) {
                            UserSearchResultView(user: user)
                                .tint(.primary)
                        }
                        .accessibilityHint("Navigates to \(user.username)'s user profile")
                    }
                    
                    if self.viewModel.searchQueryText.isEmpty, searchHistory.isEmpty == false {
                        Text("Search History")
                            .bold()
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(searchHistory.prefix(3), id: \.name) { history in
                            Button(action: { self.cacheRouteAndNavigate(to: history) }) {
                                SearchHistoryView(history: history)
                                    .tint(.primary)
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)

        }
        .navigationTitle("Search")
        .searchable(text: $viewModel.searchQueryText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search subreddits, users, posts...")
        .autocorrectionDisabled()
        .onChange(of: self.viewModel.searchQueryText, { oldValue, newValue in
            // On immediate change of query text
            
            guard self.viewModel.searchQueryText.isEmpty == false else {
                return
            }
            
            self.viewModel.searchCachedSubreddits()
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

extension SearchPage {
    
    private func cacheRouteAndNavigate(to subreddit: SubredditSearchResult) {
        self.globalVM.addToCurrentNavStack(SubredditNavModel(subredditName: subreddit.subredditName))
        self.modelContext.insert(SearchHistoryModel(from: subreddit))
    }
    
    private func cacheRouteAndNavigate(to user: UserSearchResult) {
        self.modelContext.insert(SearchHistoryModel(from: user))
    }
    
    private func cacheRouteAndNavigate(to history: SearchHistoryModel) {
        let newHistory = history
        history.accessedAt = Date()
        self.modelContext.insert(newHistory)
        
        if newHistory.isUser {
            
        } else {
            self.globalVM.addToCurrentNavStack(SubredditNavModel(subredditName: history.name))
        }
    }
}
