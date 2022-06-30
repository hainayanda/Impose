// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Impose",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_10),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "Impose",
            targets: ["Impose"]
        )
    ],
    dependencies: [
        // uncomment this code to test
//        .package(url: "https://github.com/Quick/Quick.git", from: "5.0.1"),
//        .package(url: "https://github.com/Quick/Nimble.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "Impose",
            dependencies: [],
            path: "Impose/Classes"
        ),
        // uncomment this code to test
//        .testTarget(
//            name: "ImposeTests",
//            dependencies: [
//                "Impose", "Quick", "Nimble"
//            ],
//            path: "Example/Tests",
//            exclude: ["Info.plist"]
//        )
    ]
)
