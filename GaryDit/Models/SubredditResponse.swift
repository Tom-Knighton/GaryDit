//
//  SubredditResponse.swift
//  GaryDit
//
//  Created by Tom Knighton on 18/06/2023.
//

import Foundation

public struct SubredditPostResponse: Codable {
    
    public let kind: String
    public let data: SubredditPostResponseData
}

public struct SubredditPostResponseData: Codable {
    public let after: String
    public let dist: Int
    public let children: [SubredditPostListChild]
}

public struct SubredditPostListChild: Codable {
    public let data: RedditPost
}

public struct RedditPost: Codable {
    /// The name of the subreddit this post is from
    public let subreddit: String
    
    /// The text of the post itself
    public let selftext: String
    
    /// Whether or not the current user has saved this post
    public let saved: Bool
    
    /// The title of the post
    public let title: String
    
    /// The secure (ssl) version of the post media
    public let secureMedia: RedditPostMedia?
    
    /// Some preview gifs, videos and images of the media for this post
    public let preview: RedditPostImagePreview?
    
    /// The score (upvotes-downvotes) to display for the post
    public let score: Int
    
    /// The thumbnail url for the post
    public let thumbnail: String?
    
    /// The TimeInterval the post was edited, if nil then it has not been edited
    @NilOnTypeMismatch
    var edited: Double?
    
    /// The TimeInterval the post was created at
    public let createdUtc: Double
    
    /// Whether or not the post is archived
    public let archived: Bool
    
    /// Whether or not the post is NSFW
    public let over18: Bool
    
    /// Whether or not the post is locked
    public let locked: Bool
    
    /// The username of the post author
    public let author: String
    
    /// Whether or not the post is marked as stickied
    public let stickied: Bool
    
    /// If present, the url of the image for this post
    public let url: String?
    
    /// The number of comments on this post
    public let numComments: Int
    
    /// A hint for the 'type' of post, i.e. link,
    public let postHint: RedditPostHint?
    
}

public enum RedditPostHint: String, Codable {
    case Link = "link"
    case Image = "image"
    case RichVideo = "rich:video"
    case HostedVideo = "hosted:video"
    case SelfPost = "self"
    
    func isVideo() -> Bool {
        return self == RedditPostHint.RichVideo || self == RedditPostHint.HostedVideo
    }
}

public struct RedditPostImagePreview: Codable {
    public let images: [RedditPostImageValues]?
    public let redditVideoPreview: RedditPostMediaRedditVideo?
}

public struct RedditPostImageValues: Codable {
    public let source: RedditLink?
//    public let resolutions: RedditLink?
    public let variants: RedditPostImageVariants?
}

public class RedditPostImageVariants: Codable {
    public let gif: RedditPostImageValues?
    public let mp4: RedditPostImageValues?
}

public struct RedditLink: Codable {
    public let url: String
    public let width: Double
    public let height: Double
}

public struct RedditPostMedia: Codable {
    public let redditVideo: RedditPostMediaRedditVideo?
    public let oembed: RedditPostMediaOembed?
    public let type: String?
}

public struct RedditPostMediaRedditVideo: Codable {
    public let hasAudio: Bool?
    public let height: Double
    public let width: Double
    public let duration: Int
    public let dashUrl: String?
    public let hlsUrl: String?
    public let isGif: Bool
    public let fallbackUrl: String?
}

public struct RedditPostMediaOembed: Codable {
    public let providerUrl: String?
    public let title: String?
    public let authorName: String?
    public let providerName: String?
    public let thumbnailUrl: String?
    public let authorUrl: String?
    public let width: Double
    public let height: Double
}


extension RedditPost {
    
    var friendlyCreatedAgo: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: Date(timeIntervalSince1970: self.createdUtc), to: Date()) ?? "", locale: .current)
    }
    
    func getPostType() -> RedditPostHint {
        return self.postHint ?? .SelfPost
    }
    
    func extractMedia() -> GenericMedia? {
        if self.postHint == .Image {
            if let first = self.preview?.images?.first {
                if let mp4 = first.variants?.mp4, let mp4Source = mp4.source {
                    return GenericMedia(urlString: mp4Source.url, width: mp4Source.width, height: mp4Source.height, isVideo: true)
                }
                if let gif = first.variants?.gif, let gifSource = gif.source {
                    return GenericMedia(urlString: gifSource.url, width: gifSource.width, height: gifSource.height, isVideo: true)
                }
                
                if let source = first.source {
                    return GenericMedia(urlString: source.url, width: source.width, height: source.height, isVideo: false)
                }
            }
            
            return GenericMedia(urlString: self.url ?? "", width: 0, height: 0, isVideo: false)
        }
        
        if self.postHint == .HostedVideo {
            if let media = self.secureMedia, let redditVideo = media.redditVideo {
                if let url = redditVideo.hlsUrl {
                    return GenericMedia(urlString: url, width: redditVideo.width, height: redditVideo.height, isVideo: true)
                }
                return GenericMedia(urlString: redditVideo.fallbackUrl ?? "", width: redditVideo.width, height: redditVideo.height, isVideo: true)
            }
        }
        
        if self.postHint == .RichVideo {
            if let media = self.secureMedia, let oembed = media.oembed {
                if let url = self.url {
                    return GenericMedia(urlString: url, width: oembed.width, height: oembed.height, isVideo: true)
                }
            }
        }
        
        if self.postHint == .Link {
            if let vidPreview = self.preview?.redditVideoPreview {
                return GenericMedia(urlString: vidPreview.hlsUrl ?? vidPreview.fallbackUrl ?? "", width: vidPreview.width, height: vidPreview.height, isVideo: true)
            }
            
            return GenericMedia(urlString: self.url ?? "", width: 0, height: 0, isVideo: false)
        }
        
        return nil
    }
}

struct GenericMedia {
    let urlString: String
    let width: Double
    let height: Double
    let isVideo: Bool
    
    var aspectRatio: Double {
        return width / height
    }
}
