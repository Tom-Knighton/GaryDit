//
//  SearchPageViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 15/08/2023.
//

import Foundation
import Observation
import Combine

@Observable
public class SearchPageViewModel {
    
    public var errorDidOccur: Bool = false
    public var subredditResults: [SubredditSearchResult] = []
    public var searchQueryText: String = ""
    
    
    public func searchForSubreddits() async {
        do {
            let results = try await SearchService.searchSubreddits(query: searchQueryText.trimmingCharacters(in: .whitespacesAndNewlines), includeNsfw: true)
            self.subredditResults = subredditResults
        } catch {
            self.errorDidOccur = true
        }
    }
}
