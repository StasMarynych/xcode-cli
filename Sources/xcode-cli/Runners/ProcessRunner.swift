import Foundation
import Subprocess

protocol ProcessRunnerProtocol {
    func run(
        executable: String,
        arguments: [String],
        streamOutput: Bool
    ) async throws -> ExecutionResult
}

struct ProcessRunner: ProcessRunnerProtocol {
    func run(
        executable: String,
        arguments: [String],
        streamOutput: Bool
    ) async throws -> ExecutionResult {
        let args = Arguments(arguments)
        
        if streamOutput {
            let result = try await Subprocess.run(
                .name(executable),
                arguments: args,
                output: .standardOutput,
                error: .standardError
            )
            
            return ExecutionResult(
                exitCode: extractExitCode(from: result.terminationStatus),
                stdout: "",
                stderr: ""
            )
        } else {
            let result = try await Subprocess.run(
                .name(executable),
                arguments: args,
                output: .string(limit: Int.max),
                error: .string(limit: Int.max)
            )
            
            let exitCode = extractExitCode(from: result.terminationStatus)
            let stdout = result.standardOutput ?? ""
            let stderr = result.standardError ?? ""
            
            return ExecutionResult(
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
