//
//  PostPage.swift
//  GaryDit
//
//  Created by Tom Knighton on 28/07/2023.
//

import Foundation
import SwiftUI

struct PostPage: View {
    
    var post: Post
    
    var body: some View {
        
        ZStack {
            Color.layer1.ignoresSafeArea()
            VStack {
                Spacer()
                Text(post.postTitle)
                Spacer()
            }
            
        }
        .navigationTitle(post.postTitle)
    }
}
