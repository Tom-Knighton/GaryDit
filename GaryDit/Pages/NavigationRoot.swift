//
//  NavigationRoot.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation
import SwiftUI

public struct NavigationRootPage: View {
    
    @State private var tabSelection: Int = 0
    
    public var body: some View {
        TabView(selection: $tabSelection, content: {
            NavigationView {
                PostsPage(subredditName: "gifs")
                    
            }
            .tag(0)
            .tabItem{ Label("Posts", systemImage: tabSelection == 0 ? "shield.fill" : "shield") }
            
            HomePage()
                .tag(1)
                .tabItem { Label("Account", systemImage: tabSelection == 1 ? "person.fill" : "person")}
        })
    }
}
