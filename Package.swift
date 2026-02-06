// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcode-cli",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "xcode-cli",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Subprocess", package: "swift-subprocess")
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-rpath",
                    "-Xlinker", "/Applications/Xcode-26.0.1.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-6.2/macosx"
                ])
            ]
        ),
    ]
)
