import Foundation
import Subprocess
@testable import xcode_cli

struct MockProcessRunnerWithResult: ProcessRunnerProtocol {
    let exitCode: Int
    let stdout: String
    let stderr: String

    func run(
        executable: String,
        arguments: [String],
        environment: [Environment.Key: String?],
        streamOutput: Bool
    ) async throws -> CommandResult {
        CommandResult(exitCode: exitCode, stdout: stdout, stderr: stderr)
    }
}

class MockProcessRunnerCapture: ProcessRunnerProtocol {
    var lastExecutable: String?
    var lastArguments: [String] = []
    var lastStreamOutput: Bool?

    func run(
        executable: String,
        arguments: [String],
        environment: [Environment.Key: String?],
        streamOutput: Bool
    ) async throws -> CommandResult {
        lastExecutable = executable
        lastArguments = arguments
        lastStreamOutput = streamOutput
        return CommandResult(exitCode: 0, stdout: "", stderr: "")
    }
}
