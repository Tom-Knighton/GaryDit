//
//  GlobalStoreViewModel.swift
//  GaryDit
//
//  Created by Tom Knighton on 28/07/2023.
//

import Foundation
import Observation
import SwiftUI

class GlobalStoreViewModel: ObservableObject {
    
    @Published public var postListPath = NavigationPath()
    @Published public var searchPath = NavigationPath()
        
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
