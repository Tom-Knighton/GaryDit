//
//  ShimViewController.swift
//  GaryDit
//
//  Created by Tom Knighton on 19/06/2023.
//

import Foundation
import UIKit
import AuthenticationServices

public class ShimViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
