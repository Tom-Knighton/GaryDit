//
//  UserSearchResultView.swift
//  GaryDit
//
//  Created by Tom Knighton on 30/08/2023.
//

import Foundation
import SwiftUI

fileprivate let defaultAvatar: String = "profile_avatar_basic"

public struct UserSearchResultView: View {
    
    public let user: UserSearchResult
    
    public var body: some View {
        VStack {
            HStack {
                if let url = user.userProfileImage, !url.isEmpty {
                    CachedImageView(url: url)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .clipShape(.circle)
                } else {
                    Image(defaultAvatar)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .shadow(radius: 3)
                        .clipShape(.circle)
                }
                
                Text("u/" + user.username)
                Spacer()
            }
        }
        .padding(.all, 6)
        .background(Color.layer2)
        .clipShape(.rect(cornerRadius: 10))
    }
}
