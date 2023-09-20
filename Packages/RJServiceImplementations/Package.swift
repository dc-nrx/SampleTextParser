// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RJServiceImplementations",
	platforms: [.iOS(.v13), .macOS(.v12)],
	products: [
        .library(
            name: "RJServiceImplementations",
            targets: ["RJServiceImplementations"]),
    ],
    dependencies: [
		.package(path: "../RJCore")
    ],
    targets: [
        .target(
            name: "RJServiceImplementations",
            dependencies: ["RJCore"]),
        .testTarget(
            name: "RJServiceImplementationsTests",
            dependencies: ["RJServiceImplementations"]),
    ]
)
