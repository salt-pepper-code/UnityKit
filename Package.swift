// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "UnityKit",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "UnityKit", targets: ["UnityKit"])
    ],
    targets: [
        .target(
            name: "UnityKit",
            path: "UnityKit/UnityKit",
            exclude: []
        )
    ]
)
