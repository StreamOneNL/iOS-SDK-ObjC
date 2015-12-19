//
//  RequestError.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 25-07-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation

/**
    Errors thrown when using the Request class
*/
@objc public enum RequestError : Int {
    /**
        Error thrown if an error occurred while communicating with the API.

        This error can be used when code cannot be executed because communication with the
        API failed. It is not thrown from Request itself, but can be thrown from code using that class.
    */
    case NoSuccess = -1

    /**
        Error thrown if the body of a response can not be converted to the desired type
    */
    case CanNotConvertBody = -2

    /**
        Error thrown when user authentication is used for a SessionRequest
    */
    case UserAuthenticationNotSupported = -3

    /**
        Construct a request error from a response

        This assumes that `!response.success`

        - Parameter response: The response to construct an error for
        - Returns: The constructed error
    */
    static func fromResponse(response: Response) -> NSError {
        return NSError(domain: Constants.ErrorDomain, code: response.header.status.rawValue, userInfo: ["message": response.header.statusMessage])
    }
}