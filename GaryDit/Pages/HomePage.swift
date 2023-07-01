//
//  HomePage.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation
import SwiftUI

public struct HomePage: View {
    
    @State private var user: User?
    
    public var body: some View {
        ZStack {
            Color.layer1.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    userCard()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 0.1)
        }
        .task {
            self.user = try? await UserService.GetMe()
        }
    }
    
    @ViewBuilder
    func userCard() -> some View {
        HStack(alignment: .top) {
            userImage()
            VStack {
                Text("u/" + (user?.name ?? "..."))
                    .bold()
                    .redacted(reason: user == nil ? .placeholder : [])
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)
                Divider()
                    .padding(.vertical, 8)
                HStack {
                    Grid(horizontalSpacing: 16) {
                        GridRow {
                            Text(String(describing: (user?.totalKarma ?? 0) - (user?.linkKarma ?? 0)))
                                .bold()
                                .redacted(reason: user == nil ? .placeholder : [])
                            Text(String(describing: user?.linkKarma ?? 0))
                                .bold()
                                .redacted(reason: user == nil ? .placeholder : [])
                            Text(getDateCreatedString(date: user?.getDateTimeCreated()))
                                .bold()
                                .redacted(reason: user == nil ? .placeholder : [])
                                .multilineTextAlignment(.center)
                        }
                        GridRow(alignment: .top) {
                            Text("Comment Karma")
                                .frame(alignment: .top)
                                .multilineTextAlignment(.center)
                            Text("Post Karma")
                                .multilineTextAlignment(.center)
                            Text("Account Age")
                                .frame(alignment: .top)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.layer2)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
    }
    
    @ViewBuilder
    func userImage() -> some View {
        if let user {
            AsyncImage(url: URL(string: user.iconImg), content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }, placeholder: {
                Circle()
                    .frame(width: 60, height: 60)
                    .redacted(reason: .placeholder)
            })
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
        } else {
            Circle()
                .frame(width: 60, height: 60)
                .redacted(reason: .placeholder)
        }
    }
    
    func getDateCreatedString(date: Date?) -> String {
        
        let diffs = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date ?? Date(), to: Date())
        
        if diffs.year == 0 && diffs.month == 0 {
            if diffs.hour == 0 {
                return String(describing: diffs.minute) + "mins"
            } else if (diffs.hour ?? 0) < 24 {
                return String(describing: diffs.hour) + "hours"
            }
            return String(describing: diffs.day) + "d"
        }
        return String(describing: diffs.year ?? 0) + "Y " + String(describing: diffs.month ?? 0) + "mo"
    }
}
