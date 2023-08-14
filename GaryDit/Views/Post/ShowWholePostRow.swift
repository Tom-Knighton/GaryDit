//
//  ShowWholePostRow.swift
//  GaryDit
//
//  Created by Tom Knighton on 12/08/2023.
//

import Foundation
import SwiftUI

public struct ShowWholePostRow: View {
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Show Post")
                .bold()
            Label("You are viewing a single comment thread", systemImage: "info.circle")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.layer2)
        .clipShape(.rect(cornerRadius: 10))
        .shadow(radius: 3)
    }
}

#Preview {
    ShowWholePostRow()
}
