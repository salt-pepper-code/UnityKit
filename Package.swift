// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "UnityKit",
    platforms: [.iOS("15.0")],
    products: [
        .library(name: "UnityKit", targets: ["UnityKit"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(name: "UnityKit", dependencies: [], path: "Sources"),
        .testTarget(
            name: "UnityKitTests",
            dependencies: ["UnityKit"],
            path: "Tests"
        ),
    ]
)
