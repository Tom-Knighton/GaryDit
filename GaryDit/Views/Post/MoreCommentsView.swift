//
//  MoreCommentsView.swift
//  GaryDit
//
//  Created by Tom Knighton on 06/08/2023.
//

import Foundation
import SwiftUI

struct MoreCommentsView: View {
    
    var commentId: String
    var link: LoadMoreLink
    
    @Environment(RedditPostViewModel.self) private var postVM
    @Environment(GlobalStoreViewModel.self) private var globalVM
    @State private var isLoading: Bool = false
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Button(action: { self.loadTheseComments() }) {
                    Label(link.isContinueThreadLink ? "Continue Thread" : "Load ^[\(link.moreCount) More Comment](inflect: true)", systemImage: link.isContinueThreadLink ? "" : "chevron.down")
                }
                .padding(8)
                .background(Color.layer2)
                .clipShape(.rect(cornerRadius: 20))
                .shadow(radius: 3)
            }
            Spacer()
        }
    }
    
    func loadTheseComments() {
        if link.isContinueThreadLink {
            let vm = PostContinuedViewModel(post: postVM.post, rootId: link.parentId)
            globalVM.postListPath.append(vm)
        } else {
            self.isLoading = true
            Task.detached {
                await self.postVM.loadMoreComments(replacingId: commentId, parent: link.parentId, childIds: link.moreChildren)
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
