//
//  SafariView.swift
//  GaryDit
//
//  Created by Tom Knighton on 06/09/2023.
//
import SwiftUI
import SafariServices

public struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}
