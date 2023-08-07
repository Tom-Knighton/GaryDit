//
//  MoreCommentsView.swift
//  GaryDit
//
//  Created by Tom Knighton on 06/08/2023.
//

import Foundation
import SwiftUI

struct MoreCommentsView: View {
    
    var link: LoadMoreLink
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Label("Load ^[\(link.moreCount) More Comment](inflect: true)", systemImage: "chevron.down")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all, 4)
            }
        }
    }
}
