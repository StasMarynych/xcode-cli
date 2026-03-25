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
    .package(url: "https://github.com/swiftlang/swift-subprocess.git", branch: "main"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
  ],
  targets: [
    .executableTarget(
      name: "xcode-cli",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Subprocess", package: "swift-subprocess"),
        .product(name: "Yams", package: "Yams")
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", 
          "-rpath",
          "-Xlinker",
          "/Applications/Xcode-26.0.1.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-6.2/macosx"
        ])
      ]
    ),
    .testTarget(
      name: "xcode-cli-tests",
      dependencies: [
        "xcode-cli"
      ]
    )
  ]
)
