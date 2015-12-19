//
//  SessionStoreError.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 07-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Errors related to sessions
*/
@objc public enum SessionError : Int {
    /**
        Thrown when calling a method that requires a session but none is available
    */
    case NoSession = 2
    
    /**
        Thrown if the cache does not contain a value for the given key
    */
    case NoSuchKey = 3
}