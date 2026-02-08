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
            // Stream output in real-time
            var stdoutLines: [String] = []
            
            let result = try await Subprocess.run(
                .name(executable),
                arguments: args
            ) { execution, standardOutput in
                // Handle stdout streaming
                for try await line in standardOutput.lines() {
                    stdoutLines.append(line)
                    print(line)
                }
            }
            
            let exitCode = extractExitCode(from: result.terminationStatus)
            let stdout = stdoutLines.joined(separator: "\n")
            
            // Note: With this API, stderr is discarded when using the closure form
            // To capture stderr, we'd need to use the non-streaming version
            // For now, we'll return empty stderr when streaming
            return ExecutionResult(
                exitCode: exitCode,
                stdout: stdout,
                stderr: ""
            )
        } else {
            // Collect all output without streaming
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
