//
//  CacheService.swift
//  GaryDit
//
//  Created by Tom Knighton on 02/07/2023.
//

import Foundation

public final class Cache<Key: Hashable, Value> {
    
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()
    private let maximumEntryCount = 75
    
    init(dateProvider: @escaping () -> Date = Date.init, entryLifetime: TimeInterval = 12 * 60 * 60) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    func set(_ value: Value, forKey key: Key, expires: TimeInterval? = nil) {
        var expiryDate: Date? = nil
        if let expires {
            expiryDate = dateProvider().addingTimeInterval(expires)
        }
        let entry = Entry(key: key, value: value, expirationDate: expiryDate)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }
    
    func get(_ key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        if let expires = entry.expirationDate, dateProvider() < expires {
            remove(key)
            return nil
        }
        
        return entry.value
    }
    
    func remove(_ key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    subscript(key: Key) -> Value? {
        get { return get(key) }
        set {
            guard let value = newValue else {
                remove(key)
                return
            }
            
            set(value, forKey: key)
        }
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
    
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date?
        
        init(key: Key, value: Value, expirationDate: Date? = nil) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
    
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }
            
            keys.remove(entry.key)
        }
    }
}
