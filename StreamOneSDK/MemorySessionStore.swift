//
//  MemorySessionStore.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 07-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    In-memory session storage class

    Values in instances of memory session store are only known for the lifetime of the instance, and
    will be discarded once the instance is destroyed.
*/
public final class MemorySessionStore : NSObject, SessionStore {
    /**
        The current session ID; nil if no active session
    */
    var id: String!
    
    /**
        The current session key; nil if no active session
    */
    var key: String!
    
    /**
        The user ID of the user logged in with the current session; nil if no active session
    */
    var userId: String!
    
    /**
        The current session timeout as absolute timestamp; nil if no active session
    */
    var timeout: NSTimeInterval!
    
    /**
        Data store for cached values
    */
    var cache = [String: AnyObject]()
    
    /**
        Whether there is an active session
    */
    public var hasSession: Bool {
        // All variables need to be set to a non-nil value for an active session
        guard id != nil && key != nil && userId != nil && timeout != nil else { return false }
        
        // The timeout must not have passed yed
        if timeout < NSDate().timeIntervalSince1970 {
            clearSession()
            return false
        }
        
        // All checks passed; there is an active session
        return true
    }
    
    /**
        Clears the current active session
    */
    public func clearSession() {
        id = nil
        key = nil
        userId = nil
        timeout = nil
        cache = [String: AnyObject]()
    }
    
    /**
        Save a session to this store
        
        - Parameter id: The ID for this session
        - Parameter key: The key for this session
        - Parameter userId: The user ID for this session
        - Parameter timeout: The number of seconds before this session becomes
                             invalid when not doing any requests
    */
    public func setSession(id id: String, key: String, userId: String, timeout: NSTimeInterval) {
        self.id = id
        self.key = key
        self.userId = userId
        self.timeout = NSDate().timeIntervalSince1970 + timeout
    }
    
    /**
        Update the timeout of a session
    
        - Parameter timeout: The new timeout for the active session, in seconds from now
        - Parameter error: if an error occurred, the error that occurred
    */
    public func setTimeout(timeout: NSTimeInterval, error: NSErrorPointer) {
        guard hasSession else {
            error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSession.rawValue, userInfo: nil)
            return
        }
        self.timeout = NSDate().timeIntervalSince1970 + timeout
    }
    
    /**
        Retrieve the current session ID
    
        This function will throw if there is no active session,
    
        - Parameter error: if an error occurred, the error that occurred
    
        - Returns: The current session ID
    */
    public func getId(error: NSErrorPointer) -> String {
        guard hasSession else {
            error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSession.rawValue, userInfo: nil)
            return ""
        }
        return id
    }
    
    /**
        Retrieve the current session key
        
        This function will throw if there is no active session.
    
        - Parameter error: if an error occurred, the error that occurred
        
        - Returns: The current session key
    */
    public func getKey(error: NSErrorPointer) -> String {
        guard hasSession else {
            error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSession.rawValue, userInfo: nil)
            return ""
        }
        return key
    }
    
    /**
        Retrieve the ID of the user logged in with the current session
        
        This function will throw if there is no active session.
    
        - Parameter error: if an error occurred, the error that occurred
        
        - Returns: The ID of the user logged in with the current session
    */
    public func getUserId(error: NSErrorPointer) -> String {
        guard hasSession else {
            error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSession.rawValue, userInfo: nil)
            return ""
        }
        return userId
    }
    
    /**
        Retrieve the current session timeout
        
        This function will throw if there is no active session.
    
        - Parameter error: if an error occurred, the error that occurred

        - Returns: The number of seconds before this session expires; negative if the session has expired
    */
    public func getTimeout(error: NSErrorPointer) -> NSTimeInterval {
        guard hasSession else {
            error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSession.rawValue, userInfo: nil)
            return -1
        }
        return timeout - NSDate().timeIntervalSince1970
    }
    
    /**
        Check if a certain key is stored in the cache
        
        - Parameter key: Cache key to check for existence
        - Parameter error: if an error occurred, the error that occurred

        - Returns: True if and only if the given key is set in the cache
    */
    public func hasCacheKey(key: String, error: NSErrorPointer) -> Bool {
        guard hasSession else {
            error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSession.rawValue, userInfo: nil)
            return false
        }
        return cache[key] != nil
    }
    
    /**
        Retrieve a stored cache key
        
        This function will throw if there is no active session or if hasCacheKey returns false
        for the given key.
        
        - Parameter key: Cache key to get the cached value of
        - Parameter error: if an error occurred, the error that occurred

        - Returns: The cached value
    */
    public func getCacheKey(key: String, error: NSErrorPointer) -> AnyObject? {
        var localError: NSError?
        if !hasCacheKey(key, error: &localError) {
            if let localError = localError {
                error.memory = localError
            } else {
                error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSuchKey.rawValue, userInfo: ["key": key])
            }
            return nil
        }
        return cache[key]!
    }
    
    /**
        Store a cache key
        
        This function will throw if there is no active session.
        
        - Parameter key: Cache key to store a value for
        - Parameter value: Value to store for the given key
        - Parameter error: if an error occurred, the error that occurred
    */
    public func setCacheKey(key: String, value: AnyObject, error: NSErrorPointer) {
        guard hasSession else {
            error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSession.rawValue, userInfo: nil)
            return
        }
        cache[key] = value
    }
    
    /**
        Unset a cached value
        
        This function will throw if there is no active session or if hasCacheKey returns false
        for the given key.
        
        - Parameter key: Cache key to unset
        - Parameter error: if an error occurred, the error that occurred
    */
    public func unsetCacheKey(key: String, error: NSErrorPointer) {
        var localError: NSError?
        if !hasCacheKey(key, error: &localError) {
            if let localError = localError {
                error.memory = localError
            } else {
                error.memory = NSError(domain: Constants.ErrorDomain, code: SessionError.NoSuchKey.rawValue, userInfo: ["key": key])
            }
            return
        }
        cache.removeValueForKey(key)
    }
}