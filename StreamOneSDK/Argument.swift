//
//  Argument.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 08-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Protocol for arguments to a request
*/
@objc public protocol Argument {
    /**
        The actual value to send to the API
    */
    var value: NSString { get }
}

/**
    Let NSString conform to the Argument protocol
*/
extension NSString: Argument {
    /**
        The actual value to send to the API
    */
    public var value: NSString {
        return self
    }
}

/**
    Let NSNumber conform to the Argument protocol
*/
extension NSNumber: Argument {
    /**
        The actual value to send to the API
    */
    public var value: NSString {
        return "\(self)"
    }
}