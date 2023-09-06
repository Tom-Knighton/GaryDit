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
    
    @State private var globalViewModel = GlobalStoreViewModel.shared
    
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
                        OAuthSwift.handle(url: url)
                    }
                })
                .environment(\.openURL, OpenURLAction(handler: { url in
                    if UIApplication.shared.canOpenURL(url) {
                        self.globalViewModel.presentingUrl = url // TODO: Open in safari if user wants (settings)
                        return .handled
                    }
                    
                    return .discarded
                }))
                .environment(globalViewModel)
                .optionalModelContainer(globalViewModel.modelContainer)
                .fullScreenCover(item: $globalViewModel.presentingUrl) { url in
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
        }
    }
}
