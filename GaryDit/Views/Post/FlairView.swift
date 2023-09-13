//
//  FlairView.swift
//  GaryDit
//
//  Created by Tom Knighton on 13/09/2023.
//

import SwiftUI
import RedditMarkdownView

struct FlairView: View {
    
    let flairText: String
    
    var body: some View {
        SnudownView(text: flairText)
            .padding(3)
            .background { Color.layer1 }
            .clipShape(.rect(cornerRadius: 10))
            .shadow(radius: 1)
            .snudownShowInlineImageLinks(false)
            .snudownInlineImageWidth(7)
            .snudownFont(for: .body, .caption)
            .snudownTextAlignment(.leading)
    }
}
