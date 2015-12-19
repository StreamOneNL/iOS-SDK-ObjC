//
//  File.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 07-08-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Quick
import Nimble
@testable import StreamOneSDK

protocol SessionStoreTest {
    func constructSessionStore() -> SessionStore
}

extension SessionStoreTest {
    func runTests() {
        it("should not have a session by default") {
            expect(self.constructSessionStore().hasSession).to(equal(false))
        }

        describe("when having an active session") {
            var store: SessionStore!
            
            beforeEach {
                store = self.constructSessionStore()
                store.setSession(id: "id", key: "key", userId: "user", timeout: 10)
            }
            
            it("should have a session") {
                expect(store.hasSession).to(equal(true))
            }
            
            it("should not have a session after clearing it") {
                store.clearSession()
                expect(store.hasSession).to(equal(false))
            }
            
            it("should be able to retrieve the basic properties") {
                self.testBasicProperties(id: "id", key: "key", userId: "user_id")
                self.testBasicProperties(id: "7JhNCK-SWtEi'", key: "fAoMLYOCEpEi", userId: "_i5EDeMSEwIm")
            }
            
            it("should be able to set a cache key") {
                let key = "thisisakey"
                
                // Cache key should not be set
                var error: NSError?
                expect(store.hasCacheKey(key, error: &error)).to(equal(false))
                expect(error).to(beNil())

                error = nil
                // Set the key and test that it succeeded
                store.setCacheKey(key, value: "somerandomvalue", error: &error)
                expect(error).to(beNil())

                error = nil
                // Cache key should not be set
                expect(store.hasCacheKey(key, error: &error)).to(equal(true))
                expect(error).to(beNil())
            }
            
            it("should be able to retrieve a set cache key") {
                self.testSetGetCacheKey(store: store, key: "string", value: "string")
                self.testSetGetCacheKey(store: store, key: "int", value: 27)
                self.testSetGetCacheKey(store: store, key: "float", value: 3.14159)
                self.testSetGetCacheKey(store: store, key: "bool-true", value: true)
                self.testSetGetCacheKey(store: store, key: "bool-false", value: false)
                self.testSetGetCacheKey(store: store, key: "array-empty", value: [])
                self.testSetGetCacheKey(store: store, key: "array-values", value: [1, 2, 3])
                self.testSetGetCacheKey(store: store, key: "dictionary", value: ["a": 5, "foo": "bar"])
            }
            
            it("should be able to unset a key") {
                let key = "testUnsetCacheKey"

                var error: NSError?
                
                error = nil
                store.setCacheKey(key, value: "some random value", error: &error)
                expect(error).to(beNil())

                error = nil
                expect(store.hasCacheKey(key, error: &error)).to(equal(true))
                expect(error).to(beNil())

                error = nil
                store.unsetCacheKey(key, error: &error)
                expect(error).to(beNil())
                
                error = nil
                expect(store.hasCacheKey(key, error: &error)).to(equal(false))
                expect(error).to(beNil())
            }
            
            it("should be able to clear the cache") {
                let key = "testClearCacheKey"

                var error: NSError?

                error = nil
                store.setCacheKey(key, value: "some random value", error: &error)
                expect(error).to(beNil())

                error = nil
                expect(store.hasCacheKey(key, error: &error)).to(equal(true))
                expect(error).to(beNil())

                store.clearSession()
                store.setSession(id: "id", key: "key", userId: "user", timeout: 10)

                error = nil
                expect(store.hasCacheKey(key, error: &error)).to(equal(false))
                expect(error).to(beNil())
            }
        }
        
        describe("error throwing") {
            var store: SessionStore!
            
            beforeEach {
                store = self.constructSessionStore()
            }
            
            describe("without an active session") {
                var error: NSError?

                it("should throw a NoSession error when setting the timeout") {
                    error = nil
                    store.setTimeout(1234, error: &error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
                
                it("should throw a NoSession error when requesting the id") {
                    error = nil
                    store.getId(&error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
                
                it("should throw a NoSession error when requesting the key") {
                    error = nil
                    store.getKey(&error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
                
                it("should throw a NoSession error when requesting the userId") {
                    error = nil
                    store.getUserId(&error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
                
                it("should throw a NoSession error when requesting the timeout") {
                    error = nil
                    store.getTimeout(&error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
                
                it("should throw a NoSession error when checking for a key") {
                    error = nil
                    store.hasCacheKey("abc", error: &error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
                
                it("should throw a NoSession error when fetching a key") {
                    error = nil
                    store.getCacheKey("abc", error: &error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
                
                it("should throw a NoSession error when setting a key") {
                    error = nil
                    store.setCacheKey("abc", value: "def", error: &error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
                
                it("should throw a NoSession error when unsetting a key") {
                    error = nil
                    store.unsetCacheKey("abc", error: &error)
                    expect(error?.code).to(equal(SessionError.NoSession.rawValue))
                }
            }
            
            describe("with an active session") {
                var error: NSError?
                beforeEach {
                    store.setSession(id: "a", key: "b", userId: "c", timeout: 1234)
                }
                
                it("should throw a NoSuchKey error when fetching a key") {
                    error = nil
                    store.getCacheKey("abc", error: &error)
                    expect(error?.code).to(equal(SessionError.NoSuchKey.rawValue))
                }
                
                it("should throw a NoSuchKey error when unsetting a key") {
                    error = nil
                    store.unsetCacheKey("abc", error: &error)
                    expect(error?.code).to(equal(SessionError.NoSuchKey.rawValue))
                }
            }
        }
        
        it("should have an initial timeout") {
            // Use a fixed timeout
            let timeout: NSTimeInterval = 10
            
            // Store current time to obtain a bound on maximum timeout change
            let startTime = NSDate().timeIntervalSince1970
            
            // Construct store and set a session
            let store = self.constructSessionStore()
            store.setSession(id: "id", key: "key", userId: "user", timeout: timeout)
            
            // Retrieve the stored timeout
            var error: NSError?
            let newTimeout = store.getTimeout(&error)
            expect(error).to(beNil())

            // Calculate maximum time passed
            let timePassed = (NSDate().timeIntervalSince1970 - startTime)
                
            // Check whether timeout decay is within margins
            let timeoutDiff = timeout - newTimeout
                
            expect(timeoutDiff).to(beLessThanOrEqualTo(timePassed))
        }
        
        it("should be possible to update the timeout") {
            // Construct store and set a session with a low timeout
            let store = self.constructSessionStore()
            store.setSession(id: "id", key: "key", userId: "user", timeout: 5)
            
            // Use a fixed timeout
            let timeout: NSTimeInterval = 20
            
            // Store current time to obtain a bound on maximum timeout change
            let startTime = NSDate().timeIntervalSince1970

            var error: NSError?
            // Update timeout
            store.setTimeout(timeout, error: &error)
            expect(error).to(beNil())

            error = nil
            // Retrieve the stored timeout
            let newTimeout = store.getTimeout(&error)
            expect(error).to(beNil())
            
            // Calculate maximum time passed
            let timePassed = (NSDate().timeIntervalSince1970 - startTime)
            
            // Check whether timeout decay is within margins
            let timeoutDiff = timeout - newTimeout
            
            expect(timeoutDiff).to(beLessThanOrEqualTo(timePassed))
        }
        
        it("should actually timeout after the given timeout") {
            // Construct store and set a session with 0.3 second timeout
            let store = self.constructSessionStore()
            store.setSession(id: "id", key: "key", userId: "user", timeout: 0.3)
            
            // There should be an active session
            expect(store.hasSession).to(equal(true))
            
            // The session should be inactive eventually, wait for at most 0.5 seconds
            expect(store.hasSession).toEventually(equal(false), timeout: 0.5)
        }
    }
    
    func testBasicProperties(id id: String, key: String, userId: String) {
        let timeout: NSTimeInterval = 10
        
        let store = constructSessionStore()
        store.setSession(id: id, key: key, userId: userId, timeout: timeout)
        
        expect(store.hasSession).to(equal(true))

        var error: NSError?
        
        error = nil
        let idFromStore = store.getId(&error)
        expect(error).to(beNil())

        error = nil
        let keyFromStore = store.getKey(&error)
        expect(error).to(beNil())

        error = nil
        let userIdFromStore = store.getUserId(&error)
        expect(error).to(beNil())
        
        expect(idFromStore).to(equal(id))
        expect(keyFromStore).to(equal(key))
        expect(userIdFromStore).to(equal(userId))
    }
    
    func testSetGetCacheKey<T: Equatable>(store store: SessionStore, key: String, value: T) {
        var error: NSError?

        error = nil
        store.setCacheKey(key, value: value as! AnyObject, error: &error)
        expect(error).to(beNil())

        error = nil
        expect(store.hasCacheKey(key, error: &error)).to(equal(true))
        expect(error).to(beNil())

        error = nil
        expect(store.getCacheKey(key, error: &error) as? T).to(equal(value))
        expect(error).to(beNil())
    }
}