//
//  Role.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry

/**
    A role as returned from the API
*/
public class Role : NSObject, Decodable {
    /// Role ID
    public let id: String

    /// The name of this role
    public let name: String

    /// The customer of this role, if any
    public let customer: BasicCustomer?

    /// Tokens for this role
    public let tokens: [String]

    /**
        Construct a new role

        - Parameter id: The ID of the role
        - Parameter name: The name of the role
        - Parameter customer: The customer of the role
        - Parameter tokens: The tokens of the role
    */
    public init(id: String, name: String, customer: BasicCustomer?, tokens: [String]) {
        self.id = id
        self.name = name
        self.customer = customer
        self.tokens = tokens
    }

    /**
        Decode a JSON object into a role

        - Parameter json: The JSON to decode
        - Returns: The decoded role
    */
    public static func decode(json: JSON) -> Decoded<Role> {
        return curry(Role.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <|? "customer"
            <*> json <|| "tokens"
    }
}