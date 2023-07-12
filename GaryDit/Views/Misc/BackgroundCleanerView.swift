//
//  BackgroundCleanerView.swift
//  GaryDit
//
//  Created by Tom Knighton on 09/07/2023.
//

import Foundation
import SwiftUI

struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
