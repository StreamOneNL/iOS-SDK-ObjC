//
//  DigestTest.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 09-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

class DigestTest : QuickSpec {
    override func spec() {
        it("should be able to sign using HMAC-SHA1") {
            self.testSigning("abc", key: "abc",
                expectedSignature: "5b333a389b4e9a2358ac5392bf2a64dc68e3c943")
            self.testSigning("/api/item/view?account=uxyvA9&format=json&searchtitle=Test",
                key: "thisisareallylongkey",
                expectedSignature: "256f862ebd2d1e49e76fd2d24fa83034b7e7fe33")

        }
    }

    func testSigning(input: String, key: String, expectedSignature: String) {
        let signature = input.sign(.SHA1, key: key)

        expect(signature).to(equal(expectedSignature))
    }
}