//
//  GIFView.swift
//  GaryDit
//
//  Created by Tom Knighton on 20/06/2023.
//

import Foundation
import SwiftUI
import FLAnimatedImage


struct GIFImage: UIViewRepresentable {
    
    private var urlString: String
    private var data: Data?
    
    public init(_ urlString: String) {
        self.urlString = urlString
    }
    
    func makeUIView(context: Context) -> UIGIFImage {
        let view = UIGIFImage(frame: .zero)
        Task {
            guard let url = URL(string: urlString) else { return }
            if let (urlData, _) = try? await URLSession.shared.data(from: url) {
                view.updateGIF(data: urlData)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        Task {
            guard let url = URL(string: urlString) else { return }
            if let (urlData, _) = try? await URLSession.shared.data(from: url) {
                uiView.updateGIF(data: urlData)
            }
        }
    }
}

class UIGIFImage: UIView {
    private let imageView = UIImageView()
    private var data: Data?
    private var name: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    convenience init(data: Data) {
        self.init()
        self.data = data
        initView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        self.addSubview(imageView)
    }
    
    func updateGIF(data: Data) {
        updateWithImage {
            UIImage.gifImage(data: data)
        }
    }
    
    private func updateWithImage(_ getImage: @escaping () -> UIImage?) {
        DispatchQueue.global(qos: .userInitiated).async {
            let image = getImage()
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
    }
    
    private func initView() {
        imageView.contentMode = .scaleAspectFit
    }
}

extension UIImage {
    class func gifImage(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil)
        else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        let delays = (0..<count).map {
            // store in ms and truncate to compute GCD more easily
            Int(delayForImage(at: $0, source: source) * 1000)
        }
        let duration = delays.reduce(0, +)
        let gcd = delays.reduce(0, gcd)
        
        var frames = [UIImage]()
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let frame = UIImage(cgImage: cgImage)
                let frameCount = delays[i] / gcd
                
                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            } else {
                return nil
            }
        }
        
        return UIImage.animatedImage(with: frames,
                                     duration: Double(duration) / 1000.0)
    }
    
    class func gifImage(name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return gifImage(data: data)
    }
}

private func gcd(_ a: Int, _ b: Int) -> Int {
    let absB = abs(b)
    let r = abs(a) % absB
    if r != 0 {
        return gcd(absB, r)
    } else {
        return absB
    }
}

private func delayForImage(at index: Int, source: CGImageSource) -> Double {
    let defaultDelay = 1.0
    
    let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
    let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
    defer {
        gifPropertiesPointer.deallocate()
    }
    let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
    if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
        return defaultDelay
    }
    let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
    var delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                          Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                                     to: AnyObject.self)
    if delayWrapper.doubleValue == 0 {
        delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                          Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                                     to: AnyObject.self)
    }
    
    if let delay = delayWrapper as? Double,
       delay > 0 {
        return delay
    } else {
        return defaultDelay
    }
}

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
