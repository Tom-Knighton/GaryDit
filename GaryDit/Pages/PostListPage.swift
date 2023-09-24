//
//  PostListPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation
import SwiftUI

public struct PostListPage: View {
    
    @State private var viewModel: SubredditViewModel
    
    
    private var passedSubredditName: String
    
    init(subreddit: String? = nil) {
        passedSubredditName = subreddit ?? "All" //TODO: replace with default from settings
        self._viewModel = State(wrappedValue: SubredditViewModel(subredditName: ""))
    }
    
    init(nav: SubredditNavSearchQuery) {
        passedSubredditName = nav.searchQuery
        self._viewModel = State(wrappedValue: SubredditViewModel(subredditName: nav.subredditToSearch, searchQuery: nav.searchQuery))
    }
    
    public var body: some View {
        ZStack {
            Color.layer1.ignoresSafeArea()
            SwipeViewGroup {
                List {
                    ForEach(self.viewModel.postsToDisplay, id: \.postId) { post in
                        ListPostView(post: post)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .environment(viewModel)
                    }
                    
                    if self.viewModel.isLoading {
                        HStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        
                    } else {
                        Rectangle()
                            .accessibilityHidden(true)
                            .onAppear {
                                self.viewModel.fetchPosts(nextPage: true)
                            }
                    }
                    
                    if self.viewModel.noMorePosts {
                        NoMorePostsView()
                            .padding(.horizontal, 12)
                            .listRowInsets(EdgeInsets( ))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .contentMargins([.horizontal], 12, for: .scrollContent)
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .background(Color.layer1)
                .task {
                    if !viewModel.wasFromSearch {
                        self.viewModel.setSubredditName(to: passedSubredditName, fetchPostsAutomatically: true)
                    }
                }
                .refreshable {
                    await self.viewModel.resetAndFetchPosts()
                }
                .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search \(viewModel.subredditName)...")
                .onChange(of: viewModel.searchQuery, initial: false) { oldValue, newValue in
                    Task.detached {
                        if newValue.count > 50 {
                            viewModel.searchQuery = String(newValue.prefix(50))
                        }
                        
                        if newValue.isEmpty == false {
                            Task {
                                await viewModel.search(locally: true)
                            }
                        } else {
                            viewModel.filteredPosts = nil
                        }
                    }
                }
                .onSubmit(of: .search) {
                    Task {
                        await viewModel.search(locally: false)
                    }
                }
                .navigationTitle(self.viewModel.subredditName.isEmpty ? "Loading..." : self.viewModel.subredditName)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        sortMenu()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func sortMenu() -> some View {
        Menu {
            Button(action: { viewModel.changeSortMethod(to: .hot) }) { Text("Hot"); Image(systemName: RedditSort.iconName(.hot)) }
            Menu {
                Button(action: { viewModel.changeSortMethod(to: .top) }) { Text("Top Now"); Image(systemName: RedditSort.iconName(.top)) }
                Button(action: { viewModel.changeSortMethod(to: .topToday) }) { Text("Top Today"); Image(systemName: RedditSort.iconName(.top)) }
                Button(action: { viewModel.changeSortMethod(to: .topWeek) }) { Text("Top This Week"); Image(systemName: RedditSort.iconName(.top)) }
                Button(action: { viewModel.changeSortMethod(to: .topMonth) }) { Text("Top This Month"); Image(systemName: RedditSort.iconName(.top)) }
                Button(action: { viewModel.changeSortMethod(to: .topYear) }) { Text("Top This Year"); Image(systemName: RedditSort.iconName(.top)) }
                Button(action: { viewModel.changeSortMethod(to: .topAll) }) { Text("Top All Time"); Image(systemName: RedditSort.iconName(.top)) }
            } label: {
                Text("Top"); Image(systemName: RedditSort.iconName(.top))
            }
            
            Button(action: { viewModel.changeSortMethod(to: .new) }) { Text("New"); Image(systemName: RedditSort.iconName(.new)) }
            Button(action: { viewModel.changeSortMethod(to: .rising) }) { Text("Rising"); Image(systemName: RedditSort.iconName(.rising)) }
            Menu {
                Button(action: { viewModel.changeSortMethod(to: .controversial) }) { Text("Controversial Now"); Image(systemName: RedditSort.iconName(.controversial)) }
                Button(action: { viewModel.changeSortMethod(to: .controversialToday) }) { Text("Controversial Today"); Image(systemName: RedditSort.iconName(.controversial)) }
                Button(action: { viewModel.changeSortMethod(to: .controversialWeek) }) { Text("Controversial This Week"); Image(systemName: RedditSort.iconName(.controversial)) }
                Button(action: { viewModel.changeSortMethod(to: .controversialMonth) }) { Text("Controversial This Month"); Image(systemName: RedditSort.iconName(.controversial)) }
                Button(action: { viewModel.changeSortMethod(to: .controversialYear) }) { Text("Controversial This Year"); Image(systemName: RedditSort.iconName(.controversial)) }
                Button(action: { viewModel.changeSortMethod(to: .controversialAll) }) { Text("Controversial All Time"); Image(systemName: RedditSort.iconName(.controversial)) }
            } label: {
                Text("Controversial"); Image(systemName: RedditSort.iconName(.controversial))
            }
        } label: {
            Image(systemName: RedditSort.iconName(self.viewModel.sortMethod))
        }
        
    }
}
