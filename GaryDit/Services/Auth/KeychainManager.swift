//
//  KeychainManager.swift
//  GaryDit
//
//  Created by Tom Knighton on 17/06/2023.
//

import Foundation
import Security

private let SecMatchLimit: String! = kSecMatchLimit as String
private let SecReturnData: String! = kSecReturnData as String
private let SecReturnPersistentRef: String! = kSecReturnPersistentRef as String
private let SecValueData: String! = kSecValueData as String
private let SecAttrAccessible: String! = kSecAttrAccessible as String
private let SecClass: String! = kSecClass as String
private let SecAttrService: String! = kSecAttrService as String
private let SecAttrGeneric: String! = kSecAttrGeneric as String
private let SecAttrAccount: String! = kSecAttrAccount as String
private let SecAttrAccessGroup: String! = kSecAttrAccessGroup as String
private let SecReturnAttributes: String = kSecReturnAttributes as String

public actor KeychainManager {
        
    private let serviceName = Bundle.main.bundleIdentifier
    
    
    /// Returns the data, if found, from a key in the Keychain
    /// - Parameter key: the key to search under
    /// - Returns: The data returned as a Codable object, nil if not found
    func get<T: Codable>(_ key: String) -> T? {
        guard let keychainData = data(for: key) else {
            return nil
        }
        
        do {
            print(String(data: keychainData, encoding: .utf8))
            return try keychainData.decode(to: T.self)
        } catch {
            print("Deleting token as failed to decode")
            delete(key: key)
            return nil
        }
    }
    
    func delete(key: String) {
        var keychainQueryDict: [String: Any] = setupKeychainQueryDictionary(forKey: key)
        keychainQueryDict[SecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        SecItemDelete(keychainQueryDict as CFDictionary)
    }
    
    /// Sets a Codable struct value for a key in Keychain
    /// - Parameters:
    ///   - value: The Codable entity to store
    ///   - key: The key to store under
    /// - Returns: True if success, false if not
    func set<T: Codable>(_ value: T, for key: String) {
        let dataRep = value.toJson()
        guard let dataRep else {
            return
        }
        
        var keychainQueryDict: [String: Any] = setupKeychainQueryDictionary(forKey: key)
        keychainQueryDict[SecValueData] = dataRep
        keychainQueryDict[SecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
        
        let status: OSStatus = SecItemAdd(keychainQueryDict as CFDictionary, nil)
        
        if status == errSecSuccess {
            return
        } else if status == errSecDuplicateItem{
            update(value, for: key)
        } else {
            return
        }
    }
    
    private func update<T: Codable>(_ value: T, for key: String) {
        let dataRep = value.toJson()
        guard let dataRep else {
            return
        }
        
        var keychainQueryDict: [String: Any] = setupKeychainQueryDictionary(forKey: key)
        var updateDict = [SecValueData: dataRep]
        
        let status: OSStatus = SecItemUpdate(keychainQueryDict as CFDictionary, updateDict as CFDictionary)
        
        if status == errSecSuccess {
            return
        } else {
            return
        }
    }
    
    private func data(for key: String) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key)
        
        keychainQueryDictionary[SecMatchLimit] = kSecMatchLimitOne
        keychainQueryDictionary[SecReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
    
    private func setupKeychainQueryDictionary(forKey key: String) -> [String:Any] {
        // Setup default access as generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: [String:Any] = [kSecClass as String:kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[SecAttrService] = serviceName
        
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: Data? = key.data(using: String.Encoding.utf8)
        
        keychainQueryDictionary[SecAttrGeneric] = encodedIdentifier
        
        keychainQueryDictionary[SecAttrAccount] = encodedIdentifier
        
        return keychainQueryDictionary
    }
}
