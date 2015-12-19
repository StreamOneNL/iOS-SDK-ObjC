//
//  Digest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 09-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

// This file is based on:
// - https://github.com/SwiftP2P/SwiftSSL/blob/master/SwiftSSL/HMAC.swift
// - http://stackoverflow.com/a/24411522/313633
//
// We have removed all non SHA1 algorithms as we do not need them

import Foundation
import CommonCrypto


/**
    Enum containing supported HMAC algorithms
*/
internal enum HMACAlgorithm {
    /**
        Use HMAC-SHA1
    */
    case SHA1

    /**
        Convert the algorithm to the CommonCrypto algorithm
    
        - Returns: the CommonCrypto algorithm
    */
    func toCCEnum() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .SHA1:
            result = kCCHmacAlgSHA1
        }
        return CCHmacAlgorithm(result)
    }

    /**
        Determine the lenght of the digest

        - Returns: The length of the digest
    */
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    /**
        Sign a string using a HMAC-SHA1 algorithm
    */
    internal func sign(algorithm: HMACAlgorithm, key: String) -> String {
        // Convert the key and the data itself to NSData
        if let cKey = key.dataUsingEncoding(NSUTF8StringEncoding),
            cData = self.dataUsingEncoding(NSUTF8StringEncoding) {
                // The resulting signature will be in result
                var result = [CUnsignedChar](count: algorithm.digestLength(), repeatedValue: 0)

                // Actually sign the data
                CCHmac(algorithm.toCCEnum(), cKey.bytes, cKey.length, cData.bytes, cData.length, &result)

                // Convert the result to a (readable) string
                var hash: String = ""
                for i in 0..<algorithm.digestLength() {
                    hash += String(format: "%02x", result[i])
                }

                return hash
        }

        // Converting to NSData should never fail
        return ""
    }
}