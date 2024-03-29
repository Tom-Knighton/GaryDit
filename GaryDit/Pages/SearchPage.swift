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
                    
                    if self.viewModel.searchQueryText.isEmpty == false {
                        Button(action: { self.viewModel.searchAllOfReddit() }) {
                            Text("Search all of Reddit...")
                                .padding(.all, 6)
                                .frame(maxWidth: .infinity, idealHeight: 40)
                                .background(Color.layer2)
                                .clipShape(.rect(cornerRadius: 10))
                                .shadow(radius: 3)
                        }
                    }
                    
                    if self.viewModel.searchQueryText.isEmpty, searchHistory.isEmpty == false {
                        Text("Search History")
                            .bold()
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(searchHistory.prefix(3), id: \.name) { history in
                            SwipeView {
                                Button(action: { self.cacheRouteAndNavigate(to: history) }) {
                                    SearchHistoryView(history: history)
                                        .tint(.primary)
                                }
                            } trailingActions: { _ in
                                SwipeAction(systemImage: "trash.circle.fill", backgroundColor: .red, action: { self.removeFromHistory(history) })
                            }
                        }
                    }
                    
                    if self.viewModel.trendingSubreddits.isEmpty == false {
                        Text("Trending Subreddits:")
                            .bold()
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(self.viewModel.trendingSubreddits.prefix(5), id: \.self) { trend in
                            Button(action: { self.cacheRouteAndNavigate(to: trend)}) {
                                TrendingSubredditView(subredditName: trend)
                            }
                        }
                    }
                    
                    Group {
                        Divider()
                        Text("Random:")
                            .bold()
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button(action: { self.cacheRouteAndNavigateToRandom(nsfw: false) }) {
                            RandomSubredditButton(isNsfw: false)
                                .tint(.primary)
                        }
                        .accessibilityHint("Navigates to a random subreddit")
                        
                        Button(action: { self.cacheRouteAndNavigateToRandom(nsfw: true) }) {
                            RandomSubredditButton(isNsfw: true)
                                .tint(.primary)
                        }
                        .accessibilityHint("Navigates to a random not-safe-for-work subreddit")
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
                self.viewModel.clearUserResults()
                self.viewModel.subredditResults.removeAll()
                return
            }
            
            Task {
                self.viewModel.searchCachedSubreddits()
                self.viewModel.clearUserResults()
            }
           

        })
        .onReceive(of: self.viewModel.searchQueryText, debounceTime: 0.3) { newValue in
            // After 0.3s of no changes
            Task.detached {
                await self.viewModel.searchForSubreddits()
            }
        }
        .onReceive(of: self.viewModel.searchQueryText, debounceTime: 1) { newValue in
            // After 1s of no changes
            Task.detached {
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
        
        switch history.type {
        case .subreddit, .randSubreddit, .trendSubreddit:
            self.globalVM.addToCurrentNavStack(SubredditNavModel(subredditName: history.name))
            break
        case .searchQuery:
            self.globalVM.addToCurrentNavStack(SubredditNavSearchQuery(subredditToSearch: "All", searchQuery: history.name))
            break
        case .user:
            break
        }
    }
    
    private func cacheRouteAndNavigate(to subredditName: String) {
        self.globalVM.addToCurrentNavStack(SubredditNavModel(subredditName: subredditName))
        self.modelContext.insert(SearchHistoryModel(from: subredditName))
    }
    
    private func cacheRouteAndNavigateToRandom(nsfw: Bool) {
        
        Task.detached {
            let subreddit = try? await SubredditService.GetRandomSubreddit(nsfw: nsfw)
            if let subreddit {
                await MainActor.run {
                    self.globalVM.addToCurrentNavStack(SubredditNavModel(subredditName: subreddit))
                    self.modelContext.insert(SearchHistoryModel(from: subreddit, isRandom: true))
                }
            }
        }
    }
    
    private func removeFromHistory(_ history: SearchHistoryModel) {
        let name = history.name
        try? self.modelContext.delete(model: SearchHistoryModel.self, where: #Predicate { $0.name == name })
        try? self.modelContext.save()
    }
}
