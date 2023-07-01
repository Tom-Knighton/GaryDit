//
//  GaryDitApp.swift
//  GaryDit
//
//  Created by Tom Knighton on 16/06/2023.
//

import SwiftUI
import SwiftData
import OAuthSwift

@main
struct GaryDitApp: App {
    
    let keychainManager = KeychainManager()
    
    init() {
        //iOS changes the tab bar when there's nothing under it...
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL(perform: { url in
                    if url.host() == "garydit-oauth-cb" {
                        print(url)
                        OAuthSwift.handle(url: url)
                    }
                })
        }
    }
}
