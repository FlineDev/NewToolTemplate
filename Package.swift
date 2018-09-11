// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "{TOOL_NAME}",
    products: [
        .executable(name: "{TOOL_COMMAND}", targets: ["{TOOL_NAME}"]),
        .library(name: "{TOOL_NAME}Kit", targets: ["{TOOL_NAME}Kit"])
    ],
    dependencies: [
        .package(url: "https://github.com/kiliankoe/CLISpinner.git", .upToNextMinor(from: "0.3.5")),
        .package(url: "https://github.com/Flinesoft/HandySwift.git", .upToNextMajor(from: "2.6.0")),
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "3.1.4")),
        .package(url: "https://github.com/jakeheis/SwiftCLI", .upToNextMajor(from: "5.1.2"))
    ],
    targets: [
        .target(
            name: "{TOOL_NAME}",
            dependencies: ["{TOOL_NAME}Kit"],
            path: "Sources/{TOOL_NAME}"
        ),
        .target(
            name: "{TOOL_NAME}Kit",
            dependencies: [
                "CLISpinner",
                "HandySwift",
                "Rainbow",
                "SwiftCLI"
            ],
            path: "Sources/{TOOL_NAME}Kit"
        ),
        .testTarget(
            name: "{TOOL_NAME}KitTests",
            dependencies: ["{TOOL_NAME}Kit", "HandySwift"],
            path: "Tests/{TOOL_NAME}KitTests"
        )
    ]
)
