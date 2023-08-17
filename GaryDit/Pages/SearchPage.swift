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
        }
        .navigationTitle("Search")
        .searchable(text: $viewModel.searchQueryText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search subreddits, users, posts...")
        .autocorrectionDisabled()
    }
}
