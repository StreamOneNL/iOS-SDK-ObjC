//
//  Account.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry

/**
     A basic account as returned from the API
*/
public class BasicAccount : NSObject, Decodable {
    /// Account ID
    public let id: String

    /// The name of this account
    public let name: String

    /**
        Construct a new basic account

        - Parameter id: The ID of the account
        - Parameter name: The name of the customer
    */
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    /**
        Decode a JSON object into an account

        - Parameter json: The JSON to decode
        - Returns: The decoded account
    */
    public static func decode(json: JSON) -> Decoded<BasicAccount> {
        return curry(BasicAccount.init)
            <^> json <| "id"
            <*> json <| "name"
    }
}