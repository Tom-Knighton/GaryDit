//
//  PostViewPostDetails.swift
//  GaryDit
//
//  Created by Tom Knighton on 29/07/2023.
//

import Foundation
import SwiftUI
import MarkdownView

struct PostViewPostDetails: View {
    
    @Bindable var viewModel: RedditPostViewModel
    @State private var showMediaUrl: String? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
                        
            if viewModel.displayMediaBelowTitle == false {
                mediaView()
            }
            Text(viewModel.post.postTitle)
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .fixedSize(horizontal: false, vertical: true)
            if viewModel.displayMediaBelowTitle {
                mediaView()
            }
            
            if let text = viewModel.post.postContent.textContent {
                Spacer().frame(height: 16)
                MarkdownView(text: .constant(text))
            }
            
            Divider()
        }
        .padding(.horizontal, 12)
        .background(Color.layer1)
        .clipShape(.rect(topLeadingRadius: 0, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 0))
        .fullScreenCover(item: $showMediaUrl, content: { url in
            MediaGalleryView(selectedMediaUrl: url)
                .environment(viewModel)
                .background(BackgroundCleanerView())
        })
        .onChange(of: self.showMediaUrl, initial: true) {
            if let media = self.showMediaUrl, media.isEmpty == false {
                NotificationCenter.default.post(name: .MediaGalleryFullscreenPresented, object: nil, userInfo: ["except": self.showMediaUrl ?? ""])
            } else {
                NotificationCenter.default.post(name: .MediaGalleryFullscreenDismissed, object: nil, userInfo: [:])
            }
        }
    }
    
    @ViewBuilder
    func mediaView() -> some View {
        PostTopMediaView(showMediaUrl: $showMediaUrl, content: viewModel.post.postContent)
            .clipShape(.rect(cornerRadius: 10))
            .shadow(radius: 3)
            .environment(viewModel)
            .padding(.top, 4)
            .onAppear {
                self.viewModel.overrideVideosDontStopWhenDisappear = true
            }
            .onDisappear {
                self.viewModel.overrideVideosDontStopWhenDisappear = false
            }
    }
}
