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
                .navigationTitle(self.viewModel.subredditName.isEmpty ? "Loading..." : self.viewModel.subredditName)
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
            }
        }
    }
}
