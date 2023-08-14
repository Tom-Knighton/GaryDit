//
//  APIClient.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
    case connect = "CONNECT"
}

public struct APIRequest {
    var method: HttpMethod = .get
    let path: String
    let queryItems: [URLQueryItem]?
    let body: Data?
}

public actor APIClient {
    
    private let session = URLSession.shared
    
    private let authManager = AuthManager()
    
    private let baseUrl = URL(string: "https://" + (Bundle.main.object(forInfoDictionaryKey: "GARYDIT_API_BASE") as? String ?? "api.garydit.tomk.online"))
        
    func perform<T: Decodable>(_ request: APIRequest, allowRetry: Bool = true) async throws -> T {
        guard let baseUrl else {
            throw APIError.invalidBaseUrl
        }
        
        let url = baseUrl.appending(path: request.path).appending(queryItems: request.queryItems ?? [])
        var apiRequest = try await authorisedRequest(from: url)
        apiRequest.httpMethod = request.method.rawValue
        apiRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = request.body {
            apiRequest.httpBody = body
        }
        
        let (data, urlResponse) = try await session.data(for: apiRequest)
        
        if let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 401 {
            if allowRetry {
                _ = try await authManager.refreshToken()
                return try await perform(request, allowRetry: false)
            }
            
            throw APIError.invalidToken
        }
        
        if T.self is String.Type {
            return String(data: data, encoding: .utf8) as! T
        }
        
        
        print(url.absoluteString)
        do {
            let response = try data.decode(to: T.self)
            return response
        } catch {
            print(String(data: data, encoding: .utf8))
            print("Error ^")
            throw error
        }
    }
    
    private func authorisedRequest(from url: URL) async throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        let token = try await authManager.validToken()
        guard let token else {
            throw APIError.missingToken
        }

        urlRequest.setValue("Bearer \(token.Token)", forHTTPHeaderField: "Authorization")
        print(token.Token)
        return urlRequest
    }
}
