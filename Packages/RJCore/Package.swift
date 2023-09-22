// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RJCore",
	platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        .library(
            name: "RJServices",
            targets: ["RJServices"]),
		.library(
			  name: "RJImplementations",
			  targets: ["RJImplementations"]),
		.library(
			  name: "RJResources",
			  targets: ["RJResources"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RJServices",
            dependencies: []),
		.target(
			  name: "RJImplementations",
			  dependencies: ["RJServices"]),
		.target(
			  name: "RJResources",
			  dependencies: [],
			  resources: [.process("Resources")]),
        .testTarget(
            name: "RJCoreTests",
            dependencies: ["RJServices", "RJImplementations", "RJResources"]),
    ]
)
