import ArgumentParser
import Subprocess

extension XCodeCLI {

    struct Check: AsyncParsableCommand {

        struct CommandLineToolsCheck: AsyncParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "tools",
                abstract: "Checks if Xcode Command Line Tools are installed and ready to use"
            )

            func run() async throws {
                let result = try await Subprocess.run(
                    .path("/usr/bin/xcode-select"), 
                    arguments: ["-p"],
                    output: .string(limit: 256)
                )
                let isSuccess = result.terminationStatus.isSuccess

                if isSuccess, let path = result.standardOutput {
                    print("Command Line Tools: ✅ Installed at \(path)")
                } else {
                    print("Command Line Tools: ❌ Not installed")
                }
            }
        }

        struct XcodeCheck: AsyncParsableCommand {
            static let configuration = CommandConfiguration(
                commandName: "xcode",
                abstract: "Checks if Xcode is installed and ready to use"
            )

            func run() async throws {
                let result = try await Subprocess.run(
                    .path("/usr/bin/xcodebuild"), 
                    arguments: ["-version"],
                    output: .string(limit: 256)
                )
                let isSuccess = result.terminationStatus.isSuccess

                if isSuccess, let version = result.standardOutput {
                    print("Xcode: ✅ Installed \(version)")
                } else {
                    print("Xcode: ❌ Not installed")
                }
            }
        }

        static let configuration = CommandConfiguration(
            commandName: "check",
            abstract: "Checks if Xcode and Xcode Command Line Tools are installed and ready to use",
            subcommands: [CommandLineToolsCheck.self, XcodeCheck.self]
        )
    }
}