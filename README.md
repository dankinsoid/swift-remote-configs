# ⚠️ REPOSITORY MOVED

**This repository has been renamed and moved to: [swift-configs](https://github.com/dankinsoid/swift-configs)**

**Please update your Package.swift dependencies:**
```diff
- .package(url: "https://github.com/dankinsoid/swift-remote-configs.git", from: "1.0.0"),
+ .package(url: "https://github.com/dankinsoid/swift-configs.git", from: "1.0.0"),
```

This repository will be archived soon. All future development and releases will happen in the new repository.

---

# SwiftRemoteConfigs (DEPRECATED)
SwiftRemoteConfigs is an API package which tries to establish a common API the ecosystem can use.
To make SwiftRemoteConfigs really work for real-world workloads, we need SwiftRemoteConfigs-compatible backends which load configs from the Ri

## Getting Started

### Adding the dependency (DEPRECATED - Use swift-configs instead)
**⚠️ This dependency is deprecated. Use the new repository instead:**
```swift
.package(url: "https://github.com/dankinsoid/swift-configs.git", from: "1.0.0"),
```

<details>
<summary>Old deprecated dependency (will be removed)</summary>

To depend on the configs API package, you need to declare your dependency in your Package.swift:
```swift
.package(url: "https://github.com/dankinsoid/swift-remote-configs.git", from: "1.0.0"),
```
and to your application/library target, add "SwiftRemoteConfigs" to your dependencies, e.g. like this:
```swift
.target(name: "BestExampleApp", dependencies: [
    .product(name: "SwiftRemoteConfigs", package: "swift-remote-configs")
],
```
</details>

### Let's read a config
1. let's import the SwiftRemoteConfigs API package
```swift
import SwiftRemoteConfigs
```

2. let's define a key
```swift
public extension Configs.Keys {
    var showAd: Key<UUID> { Key("show-ad", default: false) }
}
```

3. we need to create a Configs
```swift
let remoteConfigs = Configs()
```

4. we're now ready to use it
```swift
let id = remoteConfigs.userID
```

## The core concepts

### Configs
`Configs` are used to read configs and therefore the most important type in SwiftRemoteConfigs, so their use should be as simple as possible.

## On the implementation of a configs backend (a ConfigsHandler)
Note: If you don't want to implement a custom configs backend, everything in this section is probably not very relevant, so please feel free to skip.

To become a compatible configs backend that all SwiftRemoteConfigs consumers can use, you need to do two things: 
1. Implement a type (usually a struct) that implements ConfigsHandler, a protocol provided by SwiftRemoteConfigs
2. Instruct SwiftRemoteConfigs to use your configs backend implementation.

an ConfigsHandler or configs backend implementation is anything that conforms to the following protocol
```swift
public protocol ConfigsHandler {

    func fetch(completion: @escaping (Error?) -> Void)
    func listen(_ listener: @escaping () -> Void) -> ConfigsCancellation?
    func value(for key: String) -> String?
}
```
Where `value(for key: String)` is a function that returns a value for a given key.

Instructing SwiftRemoteConfigs to use your configs backend as the one the whole application (including all libraries) should use is very simple:

```swift
ConfigsSystem.bootstrap(MyRemoteConfigs())
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

## Migration Guide

**To migrate to the new repository:**

1. **Update Package.swift:**
```diff
dependencies: [
-    .package(url: "https://github.com/dankinsoid/swift-remote-configs.git", from: "1.0.0"),
+    .package(url: "https://github.com/dankinsoid/swift-configs.git", from: "1.0.0"),
]
```

2. **No code changes needed** - All APIs remain the same
3. **Update any documentation** or references to use the new repository URL

## Implementations
There are a few implementations of ConfigsHandler that you can use in your application:

- [Firebase Remote Configs](https://github.com/dankinsoid/swift-firebase-tools)

## Author

dankinsoid, voidilov@gmail.com

## License

swift-remote-configs is available under the MIT license. See the LICENSE file for more info.
