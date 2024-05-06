// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "swift-remote-configs",
	products: [
		.library(name: "SwiftRemoteConfigs", targets: ["SwiftRemoteConfigs"]),
	],
	dependencies: [],
	targets: [
		.target(name: "SwiftRemoteConfigs", dependencies: []),
		.testTarget(name: "SwiftRemoteConfigsTests", dependencies: ["SwiftRemoteConfigs"]),
	]
)
