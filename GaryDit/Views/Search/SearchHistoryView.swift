//
//  SearchHistoryView.swift
//  GaryDit
//
//  Created by Tom Knighton on 31/08/2023.
//

import Foundation
import SwiftUI
fileprivate let defaultAvatar: String = "profile_avatar_basic"

public struct SearchHistoryView: View {
    
    @Environment(GlobalStoreViewModel.self) private var globalVM
    
    public let history: SearchHistoryModel
    
    public var body: some View {
        HStack {
            if !history.imageUrl.isEmpty {
                CachedImageView(url: history.imageUrl)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 3)
                    .clipShape(.circle)
            } else {
                if history.isUser {
                    Image(defaultAvatar)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .clipShape(.circle)
                   
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .overlay {
                            Text("r/")
                                .bold()
                                .shadow(radius: 3)
                        }
                }
               
            }
            
            Text(history.name)
            Spacer()
        }
        .padding(.all, 6)
        .background(Color.layer2)
        .clipShape(.rect(cornerRadius: 10))
    }
}
