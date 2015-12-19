//
//  AuthenticationType.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 18-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Authentication types are used to denote how to communicate with the StreamOne API
*/
@objc public enum AuthenticationType : Int {
    /**
        Authenticate as a user
    */
    case User = 1

    /**
        Authenticate as an application
    */
    case Application = 2
}