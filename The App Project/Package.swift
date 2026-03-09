// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TheAppProject",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "TheAppProject",
            targets: ["TheAppProject"]),
    ],
    dependencies: [
        // No external dependencies required - using Apple frameworks
    ],
    targets: [
        .target(
            name: "TheAppProject",
            dependencies: [],
            path: ".",
            sources: [
                "App",
                "Views", 
                "VewModels",
                "Models"
            ],
            resources: [
                .process("Resources"),
                .process("Media.xcassets")
            ]
        ),
        .testTarget(
            name: "TheAppProjectTests",
            dependencies: ["TheAppProject"]),
    ]
)

