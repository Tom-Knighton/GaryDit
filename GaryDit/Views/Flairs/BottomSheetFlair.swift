//
//  BottomSheetFlair.swift
//  GaryDit
//
//  Created by Tom Knighton on 13/09/2023.
//

import SwiftUI
import RedditMarkdownView

struct BottomSheetFlair: View {
    
    let flairText: String
    
    var body: some View {
        ViewThatFits(in: .vertical) {
            SnudownView(text: flairText)
                .snudownShowInlineImageLinks(false)
                .snudownInlineImageWidth(7)
                .snudownTextAlignment(.leading)
                .padding(4)
                .presentationCornerRadius(20)
                .presentationDetents([.height(150)])
            ScrollView {
                VStack {
                    Spacer()
                    SnudownView(text: flairText)
                        .snudownShowInlineImageLinks(false)
                        .snudownInlineImageWidth(7)
                        .snudownTextAlignment(.leading)
                        .padding(4)
                        .presentationCornerRadius(20)
                        .presentationDetents([.height(150)])
                    Spacer()
                }
                
            }
        }
        
    }
}
