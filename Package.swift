// swift-tools-version:5.1

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
    ]
)
