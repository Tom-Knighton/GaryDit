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
                    
                    if url.host() == "open-from-url" {
                        globalViewModel.handleRedditUrl(url: url)
                    }
                })
                .environment(\.openURL, OpenURLAction(handler: { url in
                    if UIApplication.shared.canOpenURL(url) {
                        print(url.absoluteString)
                        let regex = /^(?:https?:\/\/)?(?:(?:www|amp|m|i)\.)?(?:(?:reddit\.com))\/+r\/(\w+)(?:\/comments\/(\w+)(?:\/\w+\/(\w+)(?:\/?.*?[?&]context=(\d+))?)?)?/
                        let matches = url.absoluteString.matches(of: regex)
                        if matches.isEmpty == false {
                            let output = matches.first?.output
                            let subreddit = output?.1.toString()
                            let post = output?.2?.toString()
                            let comment = output?.3?.toString()
                            self.globalViewModel.handleRedditUrl(subreddit: subreddit, postId: post, commentId: comment)
                            return .handled
                        }
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
