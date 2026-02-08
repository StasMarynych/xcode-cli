import Foundation

@testable import xcode_cli

class MockProcessRunner: ProcessRunnerProtocol {
    var lastExecutable: String?
    var lastArguments: [String]?
    var lastStreamOutput: Bool?
    
    private let stdout: String
    private let stderr: String
    private let exitCode: Int
    private var responses: [(executable: String, stdout: String, stderr: String, exitCode: Int)] = []
    private var callCount = 0
    
    init(stdout: String = "", stderr: String = "", exitCode: Int = 1) {
        self.stdout = stdout
        self.stderr = stderr
        self.exitCode = exitCode
    }
    
    init(responses: [(executable: String, stdout: String, stderr: String, exitCode: Int)]) {
        self.responses = responses
        self.stdout = ""
        self.stderr = ""
        self.exitCode = 1
    }
    
    func run(
        executable: String,
        arguments: [String],
        streamOutput: Bool
    ) async throws -> ExecutionResult {
        lastExecutable = executable
        lastArguments = arguments
        lastStreamOutput = streamOutput
        
        if !responses.isEmpty {
            let response = responses[min(callCount, responses.count - 1)]
            callCount += 1
            
            if response.executable.isEmpty || executable.contains(response.executable) {
                return ExecutionResult(
                    exitCode: response.exitCode,
                    stdout: response.stdout,
                    stderr: response.stderr
                )
            }
        }
        
        if executable.contains("PlistBuddy") {
            return ExecutionResult(
                exitCode: 0,
                stdout: "com.example.MyApp",
                stderr: ""
            )
        }
        
        return ExecutionResult(
            exitCode: exitCode,
            stdout: stdout,
            stderr: stderr
        )
    }
}
