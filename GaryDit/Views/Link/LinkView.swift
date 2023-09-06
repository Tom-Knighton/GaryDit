//
//  LinkView.swift
//  GaryDit
//
//  Created by Tom Knighton on 20/06/2023.
//

import Foundation
import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

struct LinkView: View {

    private var urlString: String
    private var isCompact: Bool
    private var overrideTitle: String?
    private var overrideImage: String?
    private var aspectRatio: CGFloat? = nil
    
    @Environment(\.openURL) var openUrl
            
    init(url: String, imageUrl: String? = nil, aspectRatio: CGFloat? = nil, overrideTitle: String? = nil, isCompact: Bool = false) {
        self.urlString = url
        self.isCompact = isCompact
        self.overrideTitle = overrideTitle
        self.overrideImage = imageUrl
        self.aspectRatio = aspectRatio
    }    
    
    var body: some View {
        ZStack {
            if isCompact {
                HStack {
                    urlImage()
                        .frame(width: 60, height: 60)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                    VStack {
                        if let title = overrideTitle {
                            Text(title)
                                .lineLimit(1)
                        }
                        Text(self.urlString)
                            .lineLimit(1)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .background(Color.layer2.overlay(Material.thick))
            } else {
                urlImage()
                VStack {
                    Spacer()
                    HStack {
                        if let host = URL(string: self.urlString)?.host()  {
                            Text(host.replacingOccurrences(of: "www.", with: ""))
                                .bold()
                            Divider()
                        }
                        Text(self.urlString)
                    }
                    .frame(maxHeight: 20)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Material.regular)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            if let url = URL(string: self.urlString) {
                openUrl(url)
            }
        }
        .accessibilityHint("Opens the url: \(self.urlString)")
    }
    
    @ViewBuilder
    func urlImage() -> some View {
        CachedImageView(url: self.overrideImage ?? self.urlString)
            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 200)
            .aspectRatio(self.aspectRatio, contentMode: .fit)
    }
}
