// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "VoicePaste",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "VoicePaste",
            targets: ["VoicePaste"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts.git", from: "2.0.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin-Modern.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "VoicePaste",
            dependencies: [
                "KeyboardShortcuts",
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin-Modern")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)