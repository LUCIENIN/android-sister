// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AndroidSister",
    defaultLocalization: "zh-Hans",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "AndroidSisterCore",
            targets: ["AndroidSisterCore"]
        ),
        .executable(
            name: "AndroidSister",
            targets: ["AndroidSister"]
        ),
    ],
    targets: [
        .target(
            name: "AndroidSisterCore"
        ),
        .executableTarget(
            name: "AndroidSister",
            dependencies: ["AndroidSisterCore"]
        ),
        .testTarget(
            name: "AndroidSisterCoreTests",
            dependencies: ["AndroidSisterCore"]
        ),
    ]
)
