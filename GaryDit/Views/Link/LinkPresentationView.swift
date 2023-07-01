//
//  LinkPresentationView.swift
//  GaryDit
//
//  Created by Tom Knighton on 19/06/2023.
//

import Foundation
import SwiftUI
import LinkPresentation

class CustomLinkView: LPLinkView {
    override var intrinsicContentSize: CGSize { CGSize(width: super.intrinsicContentSize.width, height: 200) }
}

struct LinkPresentationView: UIViewRepresentable {
    
    var metaData: LPLinkMetadata
    
    func makeUIView(context: Context) -> CustomLinkView {
        let preview = CustomLinkView(metadata: metaData)
        preview.sizeToFit()
        return preview
    }
    
    func updateUIView(_ uiView: CustomLinkView, context: Context) {
        uiView.metadata = metaData
    }
}

struct URLPreviewContainer: UIViewRepresentable {

    @Binding var togglePreview: Bool

    var previewURL: URL

    func makeUIView(context: Context) -> CustomLinkView {
        let view = CustomLinkView(url: previewURL)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: previewURL) { metadata, error in
            if error == nil, let metadata = metadata {
                DispatchQueue.main.async {
                    view.metadata = metadata
                    togglePreview.toggle()
                }
            }
        }
        return view
    }

    func updateUIView(_ uiView: CustomLinkView, context: Context) {}
}
