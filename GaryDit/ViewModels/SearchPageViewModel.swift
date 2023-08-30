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
    public var userSearchResults: [UserSearchResult] = []
    public var searchQueryText: String = ""
    
    
    public func searchForSubreddits() async {
        let query = self.searchQueryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.isEmpty == false, query.lowercased().starts(with: "u/") == false, query.lowercased().starts(with: "/u/") == false else {
            return
        }
        
        do {
            let results = try await SearchService.searchSubreddits(query: searchQueryText.trimmingCharacters(in: .whitespacesAndNewlines), includeNsfw: true)
            self.subredditResults = results
        } catch {
            self.errorDidOccur = true
        }
    }
    
    public func searchForUser() async {
        var query = self.searchQueryText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        let limit = query.lowercased().starts(with: "u/") || query.lowercased().starts(with: "/u/") ? 5 : 1
        if limit > 1 {
            self.subredditResults.removeAll()
        }
        
        query = query.replacingOccurrences(of: "/u/", with: "", options: .caseInsensitive).replacingOccurrences(of: "u/", with: "", options: .caseInsensitive)
        guard query.isEmpty == false else {
            return
        }
        
        do {
            let results = try await SearchService.searchUsers(query: query, includeNsfw: true, limit: limit)
            self.userSearchResults = results
        } catch {
            self.errorDidOccur = true
        }
    }
    
    public func clearUserResults() {
        self.userSearchResults.removeAll()
    }
}
