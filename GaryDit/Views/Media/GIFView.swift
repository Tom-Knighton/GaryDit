//
//  GIFView.swift
//  GaryDit
//
//  Created by Tom Knighton on 20/06/2023.
//

import Foundation
import SwiftUI
import FLAnimatedImage

struct GIFView: UIViewRepresentable {
    
    let url: String
    @Binding var isPlaying: Bool
    
    func makeUIView(context: Context) -> UIView {
        
        let view = UIView(frame: .zero)
        
        
        
        
        view.addSubview(activityIndicator)
        
        view.addSubview(imageView)
        
        
        
        
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        
        
        
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        
        
        return view
        
    }
    
    
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
        activityIndicator.startAnimating()
        
        guard let url = URL(string: url) else { return }
        
        
        
        
        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: url) {
                
                let image = FLAnimatedImage(animatedGIFData: data)
                
                
                
                
                DispatchQueue.main.async {
                    
                    activityIndicator.stopAnimating()
                    
                    imageView.animatedImage = image
                    
                }
                
            }
            
            if isPlaying {
                imageView.startAnimating()
            } else {
                imageView.stopAnimating()
            }
        }
        
    }
    
    
    
    private let imageView: FLAnimatedImageView = {
        
        let imageView = FLAnimatedImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // UNCOMMENT TO ADD ROUNDING TO YOUR VIEW
        
        //      imageView.layer.cornerRadius = 24
        
        imageView.layer.masksToBounds = true
        
        return imageView
        
    }()
    
    
    
    
    private let activityIndicator: UIActivityIndicatorView = {
        
        let activityIndicator = UIActivityIndicatorView()
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.color = .systemBlue
        
        return activityIndicator
        
    }()
    
}

//struct GIFView: UIViewRepresentable {
//
//    @State private var urlString: String
//    @Binding var isPlaying: Bool
//
//
//    init(urlString: String, isPlaying: Binding<Bool>) {
//        self.urlString = urlString
//        self._isPlaying = isPlaying
//    }
//
//    func makeUIView(context: Context) -> FLAnimatedImageView {
//        let gifView = FLAnimatedImageView(frame: .zero)
//
//        Task {
//            guard let url = URL(string: urlString) else { return }
//            if let (data, _) = try? await URLSession.shared.data(from: url) {
//                let image = FLAnimatedImage(gifData: data)
//                gifView.animatedImage = image
//            }
//        }
//
//        return gifView
//    }
//
//    func updateUIView(_ uiView: FLAnimatedImageView, context: Context) {
//        if (isPlaying) {
//            uiView.startAnimating()
//        } else {
//            uiView.stopAnimating()
//        }
//    }
//}
