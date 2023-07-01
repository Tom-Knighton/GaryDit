//
//  LandingPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 16/06/2023.
//

import Foundation
import SwiftUI

struct LandingPage: View {
    
    var body: some View {
        ZStack {
            Color.layer1.ignoresSafeArea()
            VStack {
                Text("Garyddit")
                    .bold()
                Spacer()
                LottieView(lottieFile: "sloth")
                    .frame(width: 300, height: 300)
                Spacer()
                
                Text("Welcome to Garryddit.")
                    .font(.title)
                    .bold()
                Text("Login with Reddit below to use Garryddit")
                    .font(.subheadline)
                Button(action: {
                    Task {
                        try! await AuthManager().beginOAuthFlow()
                    }
                }, label: {
                    Text("Login to Reddit")
                        .frame(maxWidth: .infinity)
                        .bold()
                        .padding(.vertical, 8)
                })
                    .buttonStyle(.borderedProminent)
                Spacer().frame(height: 16)
            }
            .padding(.horizontal, 16)
        }
    }
}
