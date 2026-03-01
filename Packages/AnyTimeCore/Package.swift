// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AnyTimeCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AnyTimeCore",
            targets: ["AnyTimeCore"]
        )
    ],
    targets: [
        .target(
            name: "AnyTimeCore"
        ),
        .testTarget(
            name: "AnyTimeCoreTests",
            dependencies: ["AnyTimeCore"]
        )
    ]
)
