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
        guard self.searchQueryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            return
        }
        
        do {
            let results = try await SearchService.searchSubreddits(query: searchQueryText.trimmingCharacters(in: .whitespacesAndNewlines), includeNsfw: true)
            self.subredditResults = results
        } catch {
            self.errorDidOccur = true
        }
    }
}
