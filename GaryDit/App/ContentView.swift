//
//  ContentView.swift
//  GaryDit
//
//  Created by Tom Knighton on 16/06/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @State private var isLoading = true
    @State private var isLoggedIn = false
    
    
    var body: some View {
        ZStack {
            if (isLoading) {
                ContentUnavailableView("Loading...", systemImage: "circles.hexagonpath")
            } else if isLoggedIn {
                NavigationRootPage()
            } else {
                LandingPage()
            }
        }
        .onAppear {
            isLoading = true
            Task {
                let authManager = AuthManager()
                
                if let _ = try? await authManager.validToken() {
                    isLoggedIn = true
                }
                
                isLoading = false
            }
        }
    }
}
