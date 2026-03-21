// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Moviro",
    platforms: [.iOS(.v17)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Moviro",
            targets: ["Moviro"]),
    ],
    targets: [
        .target(
            name: "Moviro",
            path: "Sources"),
        .testTarget(
            name: "MoviroTests",
            dependencies: ["Moviro"],
            path: "Tests"),
    ]
)
