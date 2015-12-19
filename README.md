# StreamOne iOS SDK

This is the iOS / Mac OS X / watchOS / tvOS SDK that can be used to communicate with the StreamOne Platform by using the StreamOne API version 3.

Note that SDK is meant to be used in Objective-C. Although it works perfectly fine in Swift (it is even written in it),
there is a [separate SDK](https://github.com/StreamOneNL/iOS-SDK) which is fully optimized for Swift 2.0.
This SDK is actually a fork from the Swift 2.0 version and it removes all the Swift 2.0 syntax features so it can be used with Objective-C.

## Table of contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
 * [Configuration](#configuration)
 * [Platform](#platform)
 * [Request and response](#request-and-response)
     * [Example](#example)
 * [Session](#session)
 * [Actor](#actor)
* [Other useful classes](#other-useful-classes)
* [Complete example](#complete-example)
* [Acknowledgements](#acknowledgements)
* [License and copyright](#license-and-copyright)


## Requirements

The SDK requires XCode 7 or higher. Furthermore, it supports the following platforms:

* iOS 8.0+
* Mac OS X 10.9+
* watchOS 2.0+
* tvOS 9.0+

## Installation

The recommended way to install the SDK is to use [Carthage](https://github.com/Carthage/Carthage).
To install, add the following to your `Cartfile` file:


```
github "StreamOneNL/iOS-SDK-ObjC"
```

Afterwards, you should update the package by running Carthage in the directory where the `Cartfile` file is located:

```bash
carthage update --no-use-binaries --platform ios
```

This will fetch dependencies into a "Carthage/Checkouts" folder, then build each one. Replace `--platform ios` with your platform or leave it out if you want to build for all platforms.
Note that there is a problem when buidling for tvOS, which require you to add `--no-use-binaries` with Carthage.

Next, on your application targets’ "General" settings tab, in the "Linked Frameworks and Libraries" section, drag and drop the following frameworks from the "Carthage/Build" folder on disk (use the correct subfolder for your target):

* `Alamofire.framework`
* `Argo.framework`
* `CommonCrypto.framework`
* `Crypto.framework`
* `Curry.framework`
* `JFCommon.framework`
* `StreamOneSDK.framework`

Next, for iOS, on your application targets’ "Build Phases" tab, click the "+" icon and choose "New Run Script Phase". Create a Run Script with the following contents:

```bash
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks "Input Files", e.g.:

```
$(SRCROOT)/Carthage/Build/iOS/Alamofire.framework
$(SRCROOT)/Carthage/Build/iOS/Argo.framework
$(SRCROOT)/Carthage/Build/iOS/CommonCrypto.framework
$(SRCROOT)/Carthage/Build/iOS/Crypto.framework
$(SRCROOT)/Carthage/Build/iOS/Curry.framework
$(SRCROOT)/Carthage/Build/iOS/JFCommon.framework
$(SRCROOT)/Carthage/Build/iOS/StreamOneSDK.framework
```

This script works around an [App Store submission bug](http://www.openradar.me/radar?id=6409498411401216) triggered by universal binaries.

For Mac OS X and watchOS you can just add the above frameworks as embedded binaries of your target.

For more information or for custom setups please see the [Carthage](https://github.com/Carthage/Carthage) website.

After adding the libraries, you need to make sure that "Embedded Content Contains Swift Code" is set to "yes".
To do this, go to your application target again and go to the "Build Settings" tab. Search for "Swift" and make sure "Embedded Content Contains Swift Code" is set to "yes".

## Usage

To use the StreamOne SDK, you should first set up a configuration and afterwards you can start communicating with the StreamOne API.

### Configuration

To set up a configuration, you should initialize the `Config` class with the desired authentication type:

```objc
@import StreamOneSDK;

Config *config = [[Config alloc] initWithAuthenticationType:AuthenticationTypeApplication
                                            authenticatorId:@"application"
                                           authenticatorPsk:@"mypsk"];
```

The following configuration properties are available :

* **apiUrl** (defaults to `https://api.streamonecloud.net`): this should be the base URL of the API to use.
* **defaultAccountId** (optional): this can be set to the ID of an account and if set, this will be the account to use by default for all API actions.
* **requestFactory** (optional, defaults to `StandardRequestFactory()`): factory to use for creating requests. If you want to overwrite it you can pass something that adheres to the the `RequestFactory` protocol here.
* **requestCache** (optional, defaults to `NoopCache()`): cache to use for requests. Should be something that adheres to the `Cache` protocol.
* **tokenCache** (optional, defaults to `NoopCache()`): cache to use for tokens. Should be something that adheres to the `Cache` protocol.
* **useSessionForTokenCache** (optional, defaults to `true`): if `true`, the session will be used to store token information if using a session. Otherwise the **tokenCache** will always be used.
* **sessionStore** (optional, defaults to `MemorySessionStore()`): the session store to use to store session information and optionally token information (if **useSessionForTokenCache** is set to `true`).
* There is a convenience method `setCache` that sets both the `requestCache` and `tokenCache`.

### Platform

The Platform class is the main entry point for performing requests. You pass it the Config during creation and it allows you to perform requests, start a new session or create an actor.

Example:

```objc
@import StreamOneSDK;

Config *config = [[Config alloc] init...]; // as above

Platform *platform = [[Platform alloc] initWithConfig:config];

// Start a new request
Request *request = [platform newRequestWithCommand:@"api" action:@"info"];

// Or use a session
Session *session = [platform newSessionWithSessionStore:nil]; // You can optionally pass a different session store here

// Or create an actor
Actor *actor = [platform newActorWithSession:nil]; // You can pass a session here to use that session for this actor
```

### Request and response

A Request can be used to perform an actual request to the StreamOne API. It extends `RequestBase` which contains code that can be used by other request classes.

The following actions can be done using a request:

* Get or set a account: use the `account` property to get or set the account used for the request. By default the **defaultAccountId** from the Config will be used, if set. To clear the account, set the value to `nil`.
* Get or set multiple accounts: use the `accounts` property to get or set multiple accounts for this request. Some API actions allow you to provide more than one account.
* Get or set a customer: use the `customer` property to get or set a customer instead of an account for this request. API actions supporting multiple accounts or a customer can use this.
* Get or set the timezone using the `timezone` property. If not set the default timezone of the current actor will be used, but one might want to overwrite this.
* Set an argument by using `setArgument: (NSString *)argument value: (id<Argument>)argument`: most API actions allow and / or require arguments to be set. Use this function to provide them. An argument can either be a `String` or an `NSNumber`. `setArgumentArray` can be used to set an argument which is an array. All arguments will be converted to strings. Use the read-only `arguments` property to read the arguments again as a `[String: String]` dictionary.

After setting up a request you should call `execute()` to actually connect to the API and perform the request.
This function takes a callback that gets passed a response. Not that this callback will be called on the same thread as the caller of the function.

The callback will receive a `Response` class, which will contain the response from the API. The following can be done with the response:

* `valid`: true if and only if the API request connected to the API successfully and contains valid data.
* `header`: if `valid` is true this will return the header for this response. This header will contain:
 * `status`: the status code of the API response. `.OK` means that everything was OK.
 * `statusMessage`: the (textual) status message of the API response.
 * `allFields`: the header might contain more fields. Use this to get the value of these fields.
* `success`: true if and only if `valid` returns `true` and `header.status` returns `.OK`.
* `fromCache`: true if and only if the data came from the cache.
* `cacheAge`: if `fromCache` returns `true`, this contains the age of the cache-item.
* `cacheable`: whether this request can be cached.
* `body`: the complete body of the API response as an `id`. `nil` if `valid` returns `false`. The actual type of the body depends on the API action.
* `error`: an error if and only if `valid` is `false`. This error will contain information about why the response is not valid.

#### Example

An example API request:

```objc

Platform *platform = ... // As above

Request *request = [platform newRequestWithCommand:@"item" action:@"view"];
[request setArgument:@"itemtype" value:@"video"];

[request execute:^(Response * _Nonnull response) {
	if (response.success) {
		NSDictionary *items = response.body;
		// Do something with the items
	} else {
		// Do something with response.error and/or response.header
	}
}];
```

### Session

A Session can be used in the StreamOne platform by an application to perform API actions on behalf of a user.

To use a session, you need to authenticate as an application (by setting **authenticationType** to `application`).
Then you can use the `Session` struct to start a session and to perform actions using that session.

The Session class provides the following useful actions:

* `isActive`: returns `true` if and only if a session is active, i.e. the user is currently logged in.
* `startWithUsername:(NSString *)username password:(NSString *)password ip:(NSString *)ip callback:(void (^)(BOOL, Response *))callback;`: start a new session for the user with the given username and password.
  For the `ip` parameter you should use something that is unique to the current device, i.e. `[UIDevice currentDevice].identifierForVendor.UUIDString`. This makes sure the API can perform rate limiting when someone fails to log in too many times without succeeding.
* `end:(void (^)(BOOL))callback` can be used to end the currently active session.
* `newRequestWithCommand:(NSString *)command action:(NSString *)action` can be used to perform a request on behalf of the user for this session.

An example of using a session:

```objc

Platform *platform = ... // As above

Session *session = [platform newSessionWithSessionStore:nil];

NSString *deviceId = [UIDevice currentDevice].identifierForVendor.UUIDString;

if (!session.isActive) {
    [session startWithUsername:@"username" password:@"password" ip:deviceId callback:^(BOOL success, Response * _Nonnull lastResponse) {
        if (success) {
            Request *request = [session newRequestWithCommand:@"item" action:@"view"];
            // etc
        } else {
            // Handle error. lastResponse contains the last response sent to the API for session creation
            // This is either a session/initialize or a session/create request
        }
    }];
} else {
    Request *request = [session newRequestWithCommand:@"item" action:@"view"];
    // etc
}
```

### Actor

An Actor corresponds to a user or an application.
It can be used to perform multiple requests with the same settings, like accounts and / or customer.

Actors can also be used to check if the required tokens for an API action are available for the given actor.
Furthermore, it is possible to get a list of all the roles of an actor.
When fetching tokens or roles, the system will request these roles and tokens from the API when required and it will cache this information so this is not done for every request. The **tokenCache** from the Config will be used to store this information.

An example of using an actor:

```swift

Platform *platform = ... // As above

Actor *actor = [platform newActorWithSession:nil];
// or
Session *session = ... // As above
Actor *actor = [platform newActorWithSession:session];

actor.accounts = @[@"abcdef"];

[actor hasToken:@"item-view" callback:^(BOOL hasToken, NSError * _Nullable error) {
    if hasToken {
        Requeest *request = [actor newRequestWithCommand:@"item" action:@"view"];
        // etc
    } else {
        // Check if hasToken.error is non-nil. If so, something was wrong.
        // Otherwise the actor does not have the token
    }
}
```

## Other useful classes

There are more classes available in the StreamOne SDK:

* `FileCache`, `MemoryCache`, `NoopCache` and `SessionCache`: different cache classes storing the cache in a file, the memory, nowhere and in the current session respectively.
* `MemorySessionStore`: a session stores that stores session information in memory.
* `Password` is used when logging in using a session and can also be used when changing the password of a user.
* `Status` is an enum with all statuses that the API can report.

## Complete example

```objc

Config *config = [[Config alloc] initWithAuthenticationType:AuthenticationTypeApplication
                                            authenticatorId:@"abcdefghijkl"
                                           authenticatorPsk:@"abcdefghijklmnopqrstuvwxyzABCDEF"];
config.defaultAccountId = @"mnopqrstuvwx";

Platform *platform = [[Platform alloc] initWithConfig:config];

Request *request = [platform newRequestWithCommand:@"api" action:@"info"];

[request execute:^(Response * _Nonnull response) {
    if (response.success) {
        NSLog(@"%@", response.body);
    } else {
        // Handle response error
    }
}];
```

## Acknowledgements

* Sam Soffes for providing [Crypto](https://github.com/soffes/Crypto), an easy to use cryptographic library and a framework wrapper around CommonCrypto.
* Thoughtbot, inc. for providing both [Argo](https://github.com/thoughtbot/Argo), a great functional JSON parsing library in Swift and [Curry](https://github.com/thoughtbot/Curry), a Swift implementation for function currying.
* The Alamofire Software Foundation for providing [Alamofire](https://github.com/Alamofire/Alamofire), an elegant HTTP Networking library in Swift.
* Jay Fuerstenberg for creating [JFCommon](https://github.com/jayfuerstenberg/JFCommon), a collection of common classes. The SDK uses `JFBCrypt` to encrypt password hashes.
* Realm for creating [Jazzy](https://github.com/realm/jazzy), a documentation generation tool for Swift code.

## License and copyright

All source code is licensed under the [MIT License](LICENSE).

Copyright (c) 2015 [StreamOne B.V.](http://streamone.nl)
