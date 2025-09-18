// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeepLiveCam",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DeepLiveCam",
            targets: ["DeepLiveCam"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DeepLiveCam",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Numerics", package: "swift-numerics"),
            ]),
        .testTarget(
            name: "DeepLiveCamTests",
            dependencies: ["DeepLiveCam"]),
    ]
)
