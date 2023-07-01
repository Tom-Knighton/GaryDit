//
//  AuthManager.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation
import OAuthSwift
import AuthenticationServices

public class AuthManager: NSObject {
    
    private var session: ASWebAuthenticationSession?
    
    private let keychainManager = KeychainManager()
    private let tokenKey = "RedditAuthToken"
    private let authUrlBase = "https://www.reddit.com/api/v1/authorize.compact"
    private let tokenUrlBase = "https://www.reddit.com/api/v1/access_token"
    private let clientKey = "fKDhO-U3Zp63rQ"
    private let redirectScheme = "garydit-oauth-cb"
    
    private var refreshTask: Task<AuthToken?, Error>?
    
    private let oauthswift = OAuth2Swift(
        consumerKey: "",
        consumerSecret: "",
        authorizeUrl: "https://www.reddit.com/api/v1/authorize.compact",
        accessTokenUrl: "https://www.reddit.com/api/v1/access_token",
        responseType: "code",
        contentType: "application/json"
    )
    
    func beginOAuthFlow() async throws {
        
        let code: String? = await getOauthCode()
        
        if let code, let tokenUrl = URL(string: tokenUrlBase) {
            var request = URLRequest(url: tokenUrl)
            request.httpMethod = "POST"
            request.httpBody = "grant_type=authorization_code&code=\(code)&redirect_uri=garydit://\(redirectScheme)".data(using: .utf8)
            let auth = (clientKey + ":" + "").data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) ?? ""
            request.addValue("Basic \(auth)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let resp = try? data.decode(to: OAuthResponse.self)
            guard let resp else {
                throw APIError.invalidToken
            }
            _ =  await self.keychainManager.set(AuthToken.buildFromOauthResponse(resp), for: self.tokenKey)
        }
    }
    
    func validToken() async throws -> AuthToken? {
        if let handle = refreshTask {
            return try await handle.value
        }
        
        let currentToken: AuthToken? = await keychainManager.get(tokenKey)
        guard let currentToken else {
            throw APIError.missingToken
        }
        
        if currentToken.IsValid() {
            return currentToken
        }
        
        return try await refreshToken()
    }
    
    func refreshToken() async throws -> AuthToken? {
        if let refreshTask {
            return try await refreshTask.value
        }
        
        guard let currentToken: AuthToken = await keychainManager.get(tokenKey) else {
            throw APIError.missingToken
        }
        
        let task = Task { () throws -> AuthToken? in defer { refreshTask = nil}
            if let refreshUrl = URL(string: tokenUrlBase) {
                var request = URLRequest(url: refreshUrl)
                request.httpMethod = "POST"
                let refreshToken = currentToken.RefreshToken
                request.httpBody = "grant_type=refresh_token&refresh_token=\(refreshToken)".data(using: .utf8)
                request.setValue("Basic \("\(clientKey):\("")".data(using: .utf8)?.base64EncodedString() ?? "")", forHTTPHeaderField: "Authorization")
                let data = try? await URLSession.shared.data(for: request)
                if let data, let resp = try? data.0.decode(to: OAuthResponse.self) {
                    let newToken = AuthToken.buildFromOauthResponse(resp)
                    _ = await self.keychainManager.set(newToken, for: tokenKey)
                    print("refreshed token")
                    return newToken
                }
                
                throw APIError.missingToken
            }
            
            throw APIError.invalidBaseUrl
        }
        
        self.refreshTask = task
        
        return try await task.value
    }
    
    @MainActor
    private func getOauthCode() async -> String? {
        return await withCheckedContinuation { (continuation: CheckedContinuation<String?, Never>) in
            let authUrl = URL(string: authUrlBase)?.appending(queryItems: [.init(name: "client_id", value: "fKDhO-U3Zp63rQ"), .init(name: "response_type", value: "code"), .init(name: "state", value: "garrydit"), .init(name: "redirect_uri", value: "garydit://garydit-oauth-cb"), .init(name: "duration", value: "permanent"), .init(name: "scope", value: "creddits,modnote,modcontributors,modmail,modconfig,subscribe,structuredstyles,vote,wikiedit,mysubreddits,submit,modlog,modposts,modflair,save,modothers,read,privatemessages,report,identity,livemanage,account,modtraffic,wikiread,edit,modwiki,modself,history,flair")])
            
            if let authUrl {
                let authSession = ASWebAuthenticationSession(url: authUrl, callbackURLScheme: "garydit-oauth-cb", completionHandler: { callbackUrl, error in
                    if error == nil {
                        let code: String? = URLComponents(string: callbackUrl?.absoluteString ?? "")?.queryItems?.filter { $0.name == "code" }.first?.value
                        if let code {
                            continuation.resume(returning: code)
                        } else {
                            continuation.resume(returning: nil)
                        }
                    } else {
                        continuation.resume(returning: nil)
                    }
                })
                authSession.presentationContextProvider = self
                authSession.start()
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
    
    private func oauthRenew(currentToken: AuthToken) async -> AuthToken? {
        oauthswift.accessTokenBasicAuthentification = true
        return await withCheckedContinuation({ (continuation: CheckedContinuation<AuthToken?, Never>) in
            let params = ["grant_type": "refresh_token", "refresh_token": currentToken.RefreshToken]
            self.oauthswift.renewAccessToken(withRefreshToken: currentToken.RefreshToken, parameters: params) { result in
                switch result {
                case .success(let(_, resp, _)):
                    let data: OAuthResponse? = try? resp?.data.decode(to: OAuthResponse.self)
                    guard let data else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let authToken = AuthToken.buildFromOauthResponse(data)
                    continuation.resume(returning: authToken)
                case .failure(let error):
                    print(error.localizedDescription)
                    print(error.underlyingError.debugDescription)
                    print("failurE!!!")
                    continuation.resume(returning: nil)
                }
            }
        })
    }
}

extension AuthManager: ASWebAuthenticationPresentationContextProviding {
    
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
