// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser

@main
struct XCodeCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "xcode-cli",
        abstract: "Native Swift CLI for Xcode automation",
        version: "1.0.0",
        subcommands: [
            BuildCommand.self,
            TestCommand.self,
            RunCommand.self,
            ArchiveCommand.self,
            ExportCommand.self,
            SimulatorCommand.self,
            ValidateCommand.self,
        ]
    )
}
