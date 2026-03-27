import Foundation
import Subprocess

protocol ProcessRunnerProtocol {
    func run(
        executable: String,
        arguments: [String],
        environment: [Environment.Key: String?],
        streamOutput: Bool
    ) async throws -> CommandResult
}

extension ProcessRunnerProtocol {
    func run(
        executable: String,
        arguments: [String],
        streamOutput: Bool
    ) async throws -> CommandResult {
        try await run(
            executable: executable,
            arguments: arguments,
            environment: [:],
            streamOutput: streamOutput
        )
    }
}

struct ProcessRunner: ProcessRunnerProtocol {
    func run(
        executable: String,
        arguments: [String],
        environment: [Environment.Key: String?],
        streamOutput: Bool
    ) async throws -> CommandResult {
        let args = Arguments(arguments)
        
        if streamOutput {
            let result = try await Subprocess.run(
                .name(executable),
                arguments: args,
                environment: .inherit.updating(environment),
                output: .standardOutput,
                error: .standardOutput
            )
            
            return CommandResult(
                exitCode: extractExitCode(from: result.terminationStatus),
                stdout: "",
                stderr: ""
            )
        } else {
            let result = try await Subprocess.run(
                .name(executable),
                arguments: args,
                environment: .inherit.updating(environment),
                output: .string(limit: Int.max),
                error: .string(limit: Int.max)
            )
            
            let exitCode = extractExitCode(from: result.terminationStatus)
            let stdout = result.standardOutput ?? ""
            let stderr = result.standardError ?? ""
            
            return CommandResult(
                exitCode: exitCode,
                stdout: stdout,
                stderr: stderr
            )
        }
    }
    
    private func extractExitCode(from status: TerminationStatus) -> Int {
        switch status {
        case .exited(let code):
            Int(code)
        case .unhandledException(let code):
            Int(code)
        }
    }
}
