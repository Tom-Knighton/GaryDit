//
//  GlobalCaches.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/07/2023.
//

import Foundation
import LinkPresentation

public class GlobalCaches {
    
    public static let linkCache = Cache<String, LPLinkMetadata?>()
    public static let imageUrlDataCache = Cache<String, Data>()
}
