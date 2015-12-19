//
//  Constants.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 05-09-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Constants that will be exported to Objective-C
*/
public class Constants : NSObject {
    override private init() {}

    /**
        Error domain for errors generated in the SDK
    */
    static let ErrorDomain = "StreamOneErrorDomain"

    /**
        A general response error
    */
    static let GeneralResponseError = 1
}