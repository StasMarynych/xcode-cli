// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser

@main
struct XCodeCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "xcode-cli",
        abstract: "Friendly and simple xcodebuild",
        version: "0.0.1",
        groupedSubcommands: [
            CommandGroup(
                name: "Helper",
                subcommands: [Check.self]
            )
        ]
    )
}
