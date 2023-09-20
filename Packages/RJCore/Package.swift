// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RJCore",
	platforms: [.iOS(.v13), .macOS(.v12)],
    products: [
        .library(
            name: "RJCore",
            targets: ["RJCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RJCore",
            dependencies: []),
        .testTarget(
            name: "RJCoreTests",
            dependencies: ["RJCore"]),
    ]
)
