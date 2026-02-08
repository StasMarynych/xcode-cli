import Testing
import Foundation

@testable import xcode_cli

@Suite("Command Exit Code Propagation Tests")
struct CommandExitCodePropagationTests {
    
    @Test("CLIError preserves xcodebuild exit code for build errors")
    func testBuildErrorPreservesExitCode() {
        let buildError = BuildError.xcodebuildError(exitCode: 65, stderr: "Build failed")
        let cliError = CLIError.buildError(buildError)
        
        #expect(cliError.exitCode == 65)
    }
    
    @Test("CLIError preserves xcodebuild exit code for test errors")
    func testTestErrorPreservesExitCode() {
        let testError = TestError.xcodebuildError(exitCode: 70, stderr: "Tests failed")
        let cliError = CLIError.testError(testError)
        
        #expect(cliError.exitCode == 70)
    }
    
    @Test("CLIError preserves xcodebuild exit code for archive errors")
    func testArchiveErrorPreservesExitCode() {
        let archiveError = ArchiveError.xcodebuildError(exitCode: 72, stderr: "Archive failed")
        let cliError = CLIError.archiveError(archiveError)
        
        #expect(cliError.exitCode == 72)
    }
    
    @Test("CLIError uses default exit code for non-xcodebuild build errors")
    func testNonXcodebuildBuildErrorUsesDefaultCode() {
        let buildError = BuildError.buildFailed(message: "Internal error")
        let cliError = CLIError.buildError(buildError)
        
        #expect(cliError.exitCode == 2)
    }
    
    @Test("CLIError uses default exit code for non-xcodebuild test errors")
    func testNonXcodebuildTestErrorUsesDefaultCode() {
        let testError = TestError.testsFailed(message: "Internal error")
        let cliError = CLIError.testError(testError)
        
        #expect(cliError.exitCode == 3)
    }
    
    @Test("CLIError uses default exit code for non-xcodebuild archive errors")
    func testNonXcodebuildArchiveErrorUsesDefaultCode() {
        let archiveError = ArchiveError.archiveFailed(message: "Internal error")
        let cliError = CLIError.archiveError(archiveError)
        
        #expect(cliError.exitCode == 4)
    }
    
    @Test("CLIError uses exit code 1 for configuration errors")
    func testConfigurationErrorExitCode() {
        let configError = ConfigurationError.missingScheme
        let cliError = CLIError.configurationError(configError)
        
        #expect(cliError.exitCode == 1)
    }
    
    @Test("CLIError uses exit code 5 for simulator errors")
    func testSimulatorErrorExitCode() {
        let simError = SimulatorError.deviceNotFound(identifier: "test")
        let cliError = CLIError.simulatorError(simError)
        
        #expect(cliError.exitCode == 5)
    }
    
    @Test("CLIError uses exit code 99 for internal errors")
    func testInternalErrorExitCode() {
        let cliError = CLIError.internalError(message: "Something went wrong")
        
        #expect(cliError.exitCode == 99)
    }
    
    // MARK: - CustomNSError Protocol Conformance
    
    @Test("CLIError conforms to CustomNSError with correct errorCode")
    func testCustomNSErrorConformance() {
        let buildError = BuildError.xcodebuildError(exitCode: 65, stderr: "Build failed")
        let cliError = CLIError.buildError(buildError)
        
        // Verify CustomNSError conformance
        let nsError = cliError as NSError
        #expect(nsError.code == 65)
        #expect(nsError.domain == "com.xcode-cli.error")
    }
    
    @Test("CLIError errorCode matches exitCode property")
    func testErrorCodeMatchesExitCode() {
        let testCases: [(CLIError, Int)] = [
            (.buildError(.xcodebuildError(exitCode: 65, stderr: "")), 65),
            (.testError(.xcodebuildError(exitCode: 70, stderr: "")), 70),
            (.archiveError(.xcodebuildError(exitCode: 72, stderr: "")), 72),
            (.buildError(.buildFailed(message: "")), 2),
            (.testError(.testsFailed(message: "")), 3),
            (.archiveError(.archiveFailed(message: "")), 4),
            (.configurationError(.missingScheme), 1),
            (.simulatorError(.deviceNotFound(identifier: "")), 5),
            (.internalError(message: ""), 99),
        ]
        
        for (error, expectedCode) in testCases {
            #expect(error.exitCode == expectedCode)
            #expect((error as NSError).code == expectedCode)
        }
    }
    
    // MARK: - End-to-End Exit Code Propagation
    
    @Test("Exit code propagates from ProcessRunner through CommandExecutor")
    func testExitCodePropagationThroughExecutor() async throws {
        // Create a mock process runner that returns a specific exit code
        struct MockProcessRunner: ProcessRunnerProtocol {
            let exitCode: Int
            
            func run(
                executable: String,
                arguments: [String],
                streamOutput: Bool
            ) async throws -> ExecutionResult {
                return ExecutionResult(
                    exitCode: exitCode,
                    stdout: "mock output",
                    stderr: "mock error"
                )
            }
        }
        
        let mockRunner = MockProcessRunner(exitCode: 65)
        let executor = CommandExecutor(processRunner: mockRunner)
        
        // Create a minimal configuration
        let config = Configuration(
            workspacePath: "test.xcworkspace",
            scheme: "TestScheme",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        // Execute build and verify the exit code is preserved
        let result = try await executor.executeBuild(config: config)
        #expect(result.exitCode == 65)
        #expect(result.isSuccess == false)
    }
    
    @Test("Exit code 0 indicates success through entire flow")
    func testSuccessExitCodePropagation() async throws {
        struct MockProcessRunner: ProcessRunnerProtocol {
            func run(
                executable: String,
                arguments: [String],
                streamOutput: Bool
            ) async throws -> ExecutionResult {
                return ExecutionResult(
                    exitCode: 0,
                    stdout: "Build succeeded",
                    stderr: ""
                )
            }
        }
        
        let mockRunner = MockProcessRunner()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            workspacePath: "test.xcworkspace",
            scheme: "TestScheme",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeBuild(config: config)
        #expect(result.exitCode == 0)
        #expect(result.isSuccess == true)
    }
    
    @Test("Different exit codes propagate correctly for different commands")
    func testDifferentExitCodesForDifferentCommands() async throws {
        struct MockProcessRunner: ProcessRunnerProtocol {
            let exitCode: Int
            
            func run(
                executable: String,
                arguments: [String],
                streamOutput: Bool
            ) async throws -> ExecutionResult {
                return ExecutionResult(
                    exitCode: exitCode,
                    stdout: "",
                    stderr: "error"
                )
            }
        }
        
        let config = Configuration(
            workspacePath: "test.xcworkspace",
            scheme: "TestScheme",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        // Test build command with exit code 65
        let buildRunner = MockProcessRunner(exitCode: 65)
        let buildExecutor = CommandExecutor(processRunner: buildRunner)
        let buildResult = try await buildExecutor.executeBuild(config: config)
        #expect(buildResult.exitCode == 65)
        
        // Test test command with exit code 70
        let testRunner = MockProcessRunner(exitCode: 70)
        let testExecutor = CommandExecutor(processRunner: testRunner)
        let testResult = try await testExecutor.executeTest(config: config)
        #expect(testResult.exitCode == 70)
        
        // Test archive command with exit code 72
        let archiveRunner = MockProcessRunner(exitCode: 72)
        let archiveExecutor = CommandExecutor(processRunner: archiveRunner)
        let archiveResult = try await archiveExecutor.executeArchive(config: config)
        #expect(archiveResult.exitCode == 72)
    }
    
    // MARK: - Real Process Exit Code Tests
    
    @Test("Real process exit codes are preserved")
    func testRealProcessExitCodes() async throws {
        let runner = ProcessRunner()
        
        // Test exit code 0 (success)
        let successResult = try await runner.run(
            executable: "true",
            arguments: [],
            streamOutput: false
        )
        #expect(successResult.exitCode == 0)
        
        // Test exit code 1 (failure)
        let failureResult = try await runner.run(
            executable: "false",
            arguments: [],
            streamOutput: false
        )
        #expect(failureResult.exitCode == 1)
        
        // Test custom exit code
        let customResult = try await runner.run(
            executable: "sh",
            arguments: ["-c", "exit 42"],
            streamOutput: false
        )
        #expect(customResult.exitCode == 42)
    }
    
    // MARK: - Edge Cases
    
    @Test("Exit code preserved with empty stdout and stderr")
    func testExitCodeWithEmptyOutput() async throws {
        struct MockProcessRunner: ProcessRunnerProtocol {
            func run(
                executable: String,
                arguments: [String],
                streamOutput: Bool
            ) async throws -> ExecutionResult {
                return ExecutionResult(
                    exitCode: 65,
                    stdout: "",
                    stderr: ""
                )
            }
        }
        
        let mockRunner = MockProcessRunner()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            workspacePath: "test.xcworkspace",
            scheme: "TestScheme",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeBuild(config: config)
        #expect(result.exitCode == 65)
    }
    
    @Test("Exit code preserved with large output")
    func testExitCodeWithLargeOutput() async throws {
        struct MockProcessRunner: ProcessRunnerProtocol {
            func run(
                executable: String,
                arguments: [String],
                streamOutput: Bool
            ) async throws -> ExecutionResult {
                let largeOutput = String(repeating: "x", count: 100_000)
                return ExecutionResult(
                    exitCode: 65,
                    stdout: largeOutput,
                    stderr: largeOutput
                )
            }
        }
        
        let mockRunner = MockProcessRunner()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            workspacePath: "test.xcworkspace",
            scheme: "TestScheme",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeBuild(config: config)
        #expect(result.exitCode == 65)
    }
}
