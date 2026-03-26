import Foundation
import Subprocess

@testable import xcode_cli

class MockProcessRunner: ProcessRunnerProtocol {
    var lastExecutable: String?
    var lastArguments: [String]?
    var lastStreamOutput: Bool?

    var responses: [(executable: String, stdout: String, stderr: String, exitCode: Int)] = []
    
    private let stdout: String
    private let stderr: String
    private let exitCode: Int
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
        environment: [Environment.Key: String?],
        streamOutput: Bool
    ) async throws -> CommandResult {
        lastExecutable = executable
        lastArguments = arguments
        lastStreamOutput = streamOutput
        
        if !responses.isEmpty {
            let response = responses[min(callCount, responses.count - 1)]
            callCount += 1
            
            if response.executable.isEmpty || executable.contains(response.executable) {
                return CommandResult(
                    exitCode: response.exitCode,
                    stdout: response.stdout,
                    stderr: response.stderr
                )
            }
        }
        
        if executable.contains("PlistBuddy") {
            return CommandResult(
                exitCode: 0,
                stdout: "com.example.MyApp",
                stderr: ""
            )
        }
        
        return CommandResult(
            exitCode: exitCode,
            stdout: stdout,
            stderr: stderr
        )
    }
}
