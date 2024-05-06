# SwiftRemoteConfigs
SwiftRemoteConfigs is an API package which tries to establish a common API the ecosystem can use.
To make remoteConfigs really work for real-world workloads, we need SwiftRemoteConfigs-compatible backends which load configs from the Ri

## Getting Started

### Adding the dependency
To depend on the remote configs API package, you need to declare your dependency in your Package.swift:
```swift
.package(url: "https://github.com/dankinsoid/swift-remote-configs.git", from: "1.0.0"),
```
and to your application/library target, add "SwiftRemoteConfigs" to your dependencies, e.g. like this:
```swift
.target(name: "BestExampleApp", dependencies: [
    .product(name: "SwiftRemoteConfigs", package: "swift-remote-configs")
],
```

### Let's read a config
1. let's import the SwiftRemoteConfigs API package
```swift
import SwiftRemoteConfigs
```

2. let's define a key
```swift
public extension RemoteConfigs.Keys {
    var showAd: Key<UUID> { Key("show-ad", default: false) }
}
```

3. we need to create a RemoteConfigs
```swift
let remoteConfigs = RemoteConfigs()
```

4. we're now ready to use it
```swift
let id = remoteConfigs.userID
```

## The core concepts

### RemoteConfigs
`RemoteConfigs` are used to read configs and therefore the most important type in SwiftRemoteConfigs, so their use should be as simple as possible.

## On the implementation of a remote configs backend (a RemoteConfigsHandler)
Note: If you don't want to implement a custom remote configs backend, everything in this section is probably not very relevant, so please feel free to skip.

To become a compatible remote configs backend that all SwiftRemoteConfigs consumers can use, you need to do two things: 
1. Implement a type (usually a struct) that implements RemoteConfigsHandler, a protocol provided by SwiftRemoteConfigs
2. Instruct SwiftRemoteConfigs to use your remote configs backend implementation.

an RemoteConfigsHandler or remote configs backend implementation is anything that conforms to the following protocol
```swift
public protocol RemoteConfigsHandler {
    
    func value(for key: String) -> CustomStringConvertible?
}
```
Where `value(for key: String)` is a function that returns a value for a given key.

Instructing SwiftRemoteConfigs to use your remote configs backend as the one the whole application (including all libraries) should use is very simple:

```swift
RemoteConfigsSystem.bootstrap(MyRemoteConfigs())
```

## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/swift-remote-configs.git", from: "1.0.1")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["SwiftRemoteConfigs"])
  ]
)
```
```ruby
$ swift build
```

## Author

dankinsoid, voidilov@gmail.com

## License

swift-remote-configs is available under the MIT license. See the LICENSE file for more info.
