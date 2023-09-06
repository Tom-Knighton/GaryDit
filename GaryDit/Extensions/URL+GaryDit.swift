//
//  URL+GaryDit.swift
//  GaryDit
//
//  Created by Tom Knighton on 19/06/2023.
//

import Foundation
import LinkPresentation


extension URL {
    
    @MainActor
    func getMetadata() async -> LPLinkMetadata? {
        do {
            let provider = LPMetadataProvider()
            let meta = try await provider.startFetchingMetadata(for: self)
            return meta
        } catch {
            Logger(category: "Link Previews").warning("Failed to retrieve metadata for link \(self.absoluteString, privacy: .auto)")
            return nil
        }
    }
}

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}
