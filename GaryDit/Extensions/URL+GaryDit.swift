//
//  URL+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 19/06/2023.
//

import Foundation
import LinkPresentation


extension URL {
    
    func getMetadata() async -> LPLinkMetadata? {
        
        let provider = LPMetadataProvider()
        let meta = try? await provider.startFetchingMetadata(for: self)
        
        return meta
    }
}
