//
//  GlobalStoreViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 28/07/2023.
//

import Foundation
import Observation
import SwiftUI
import SwiftData

@Observable
class GlobalStoreViewModel {
    
    @ObservationIgnored
    public static let shared = GlobalStoreViewModel()
    
    public var postListPath = NavigationPath()
    public var searchPath = NavigationPath()
    
    public var rootTabIndex: Int = 0
    
    public var presentingUrl: URL?
    
    @ObservationIgnored
    public var modelContainer: ModelContainer? = nil
    
    init() {
        do {
            self.modelContainer = try ModelContainer(for: CachedSubredditResult.self, SearchHistoryModel.self, CachedDailyTrendingModel.self)
        }
        catch {
            print("Error: Setting up modelContainer: " + error.localizedDescription)
        }
    }
    
    
    func addToCurrentNavStack(_ value: any Hashable) {
        switch rootTabIndex {
        case 0:
            self.postListPath.append(value)
        case 1:
            self.searchPath.append(value)
        default:
            print("WARN: adding value to unknown tab index \(rootTabIndex)")
        }
    }
        
}

extension NavigationPath {
    
    /// Pops the last n views, where n is `levels`
    /// If `levels` is larger than the actual path count, the navigation stack will just go back to the first view
    /// - Parameter levels: The amount of data to remove from the path
    public mutating func goBack(_ levels: Int = 1) {
        if levels >= self.count {
            self.popToRoot()
            return
        }
        
        self.removeLast(levels)
    }
    
    /// Removes all data from the path
    public mutating func popToRoot() {
        self.removeLast(self.count)
    }
}
