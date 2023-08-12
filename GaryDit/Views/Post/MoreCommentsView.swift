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
    @State private var isLoading: Bool = false
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Button(action: { self.loadTheseComments() }) {
                    Label(link.isContinueThreadLink ? "Continue Thread" : "Load ^[\(link.moreCount) More Comment](inflect: true)", systemImage: link.isContinueThreadLink ? "" : "chevron.down")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.all, 4)
                }
            }
        }
    }
    
    func loadTheseComments() {
        self.isLoading = true
        Task.detached {
            await self.postVM.loadMoreComments(replacingId: commentId, childIds: link.moreChildren)
        }
    }
}
