// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RJViewModel",
	platforms: [.iOS(.v14), .macOS(.v12)],
	products: [
        .library(
            name: "RJViewModel",
            targets: ["RJViewModel"]),
    ],
    dependencies: [
		.package(path: "../RJCore"),
    ],
    targets: [
        .target(
            name: "RJViewModel",
			dependencies: [.product(name: "RJServices", package: "RJCore")]),
        .testTarget(
            name: "RJViewModelTests",
            dependencies: [
				"RJViewModel",
				.product(name: "RJServices", package: "RJCore"),
				.product(name: "RJImplementations", package: "RJCore"),				
			])
    ]
)
