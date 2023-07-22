//
//  PostContent.swift
//  GaryDit
//
//  Created by Tom Knighton on 07/07/2023.
//

import Foundation

/// The type of content this post holds. Note that with image and video, there may also be text to display
public enum PostContentType: String, Codable {
    case textOnly = "textOnly"
    case image = "image"
    case video = "video"
    case gif = "gif"
    case linkOnly = "linkOnly"
    case mediaGallery = "mediaGallery"
}

/// The content of this post, it's type, any text and media
public struct PostContent: Codable {
    /// The type of content
    let contentType: PostContentType
    
    /// The text content, if any, of this post
    let textContent: String?
    
    /// Any media belonging to this post
    let media: [PostMedia]
}

public struct PostMedia: Codable {
    let url: String
    let thumbnailUrl: String?
    let height: Double
    let width: Double
    let type: PostContentType?
    let hlsDashUrl: String?
    let mediaText: String?
}
