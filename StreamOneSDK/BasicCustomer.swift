//
//  Customer.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 16-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo
import Curry

/**
    A basic customer as returned from the API
*/
public class BasicCustomer : NSObject, Decodable {
    /// Customer ID
    public let id: String

    /// The name of this customer
    public let name: String

    /// When this customer was created
    public let dateCreated: String

    /// When this customer was last modified
    public let dateModified: String

    /**
        Construct a new basic customer

        - Parameter id: The ID of the account
        - Parameter name: The name of the customer
        - Parameter dateCreated: the creation date of the customer
        - Parameter dateModified: the modification date of the customer
    */
    public init(id: String, name: String, dateCreated: String, dateModified: String) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }

    /**
        Decode a JSON object into a customer

        - Parameter json: The JSON to decode
        - Returns: The decoded customer
    */
    public static func decode(json: JSON) -> Decoded<BasicCustomer> {
        return curry(BasicCustomer.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <| "datecreated"
            <*> json <| "datemodified"
    }
}