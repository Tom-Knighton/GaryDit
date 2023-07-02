//
//  NoMorePostsView.swift
//  GaryDit
//
//  Created by Tom Knighton on 02/07/2023.
//

import SwiftUI

struct NoMorePostsView: View {
    
    var body: some View {
        HStack {
            Text("That's it! You've reached the end of the feed.")
                .bold()
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [Color(hex: "#c21500"), Color(hex: "#ffc500")], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
