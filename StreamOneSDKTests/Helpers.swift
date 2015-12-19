//
//  Helpers.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 19-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

@testable import StreamOneSDK

class MyTestCache : Cache {
    @objc func getKey(key: String) -> AnyObject? {
        return nil
    }
    
    @objc func ageOfKey(key: String) -> NSTimeInterval {
        return -1
    }
    
    @objc func setKey(key: String, value: AnyObject) {}
}

class MyRequestFactory : RequestFactory {
    @objc func newRequest(command command: String, action: String, config: Config) -> Request {
        return Request(command: command, action: action, config: config)
    }
    
    @objc func newSessionRequest(command command: String, action: String, config: Config, sessionStore: SessionStore) -> SessionRequest? {
        return SessionRequest(command: command, action: action, config: config, sessionStore: sessionStore)
    }
}

class MySessionStore : SessionStore {
    @objc var hasSession: Bool {
        return false
    }
    
    @objc func clearSession() {}
    
    @objc func setSession(id id: String, key: String, userId: String, timeout: NSTimeInterval) {}
    
    @objc func setTimeout(timeout: NSTimeInterval, error: NSErrorPointer) {}
    
    @objc func getId(error: NSErrorPointer) -> String {
        return ""
    }
    
    @objc func getKey(error: NSErrorPointer) -> String {
        return ""
    }
    
    @objc func getUserId(error: NSErrorPointer) -> String {
        return ""
    }
    
    @objc func getTimeout(error: NSErrorPointer) -> NSTimeInterval {
        return 0
    }
    
    @objc func hasCacheKey(key: String, error: NSErrorPointer) -> Bool {
        return false
    }
    
    @objc func getCacheKey(key: String, error: NSErrorPointer) -> AnyObject? {
        return nil
    }
    
    @objc func setCacheKey(key: String, value: AnyObject, error: NSErrorPointer) {}
    
    @objc func unsetCacheKey(key: String, error: NSErrorPointer) {}
}