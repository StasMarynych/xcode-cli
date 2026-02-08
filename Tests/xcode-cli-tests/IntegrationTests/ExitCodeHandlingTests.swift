import Testing

@testable import xcode_cli

@Suite("Exit Code Handling Tests")
struct ExitCodeHandlingTests {
    let runner = ProcessRunner()
    
    @Test("Exit code 0 is preserved for successful commands")
    func testExitCodeZeroPreserved() async throws {
        let result = try await runner.run(
            executable: "true",
            arguments: [],
            streamOutput: false
        )
        
        #expect(result.exitCode == 0)
        #expect(result.isSuccess == true)
    }
    
    @Test("Exit code 1 is preserved for failed commands")
    func testExitCodeOnePreserved() async throws {
        let result = try await runner.run(
            executable: "false",
            arguments: [],
            streamOutput: false
        )
        
        #expect(result.exitCode == 1)
        #expect(result.isSuccess == false)
    }
    
    @Test("Specific non-zero exit codes are preserved")
    func testSpecificExitCodesPreserved() async throws {
        // Test exit code 2 using grep with no match
        let result = try await runner.run(
            executable: "grep",
            arguments: ["nonexistent_pattern_xyz123", "/dev/null"],
            streamOutput: false
        )
        
        // grep returns 1 for no match, 2 for errors
        #expect(result.exitCode == 1)
        #expect(result.isSuccess == false)
    }
    
    @Test("Exit code preserved in streaming mode")
    func testExitCodePreservedInStreamingMode() async throws {
        let result = try await runner.run(
            executable: "false",
            arguments: [],
            streamOutput: true
        )
        
        #expect(result.exitCode == 1)
        #expect(result.isSuccess == false)
    }
    
    @Test("Exit code preserved with stdout output")
    func testExitCodePreservedWithStdout() async throws {
        // sh -c "echo 'output'; exit 42" should exit with code 42
        let result = try await runner.run(
            executable: "sh",
            arguments: ["-c", "echo 'test output'; exit 42"],
            streamOutput: false
        )
        
        #expect(result.exitCode == 42)
        #expect(result.stdout.contains("test output"))
        #expect(result.isSuccess == false)
    }
    
    @Test("Exit code preserved with stderr output")
    func testExitCodePreservedWithStderr() async throws {
        // sh -c "echo 'error' >&2; exit 13" should exit with code 13
        let result = try await runner.run(
            executable: "sh",
            arguments: ["-c", "echo 'error message' >&2; exit 13"],
            streamOutput: false
        )
        
        #expect(result.exitCode == 13)
        #expect(result.stderr.contains("error message"))
        #expect(result.isSuccess == false)
    }
    
    @Test("Exit code preserved with both stdout and stderr")
    func testExitCodePreservedWithBothStreams() async throws {
        let result = try await runner.run(
            executable: "sh",
            arguments: ["-c", "echo 'stdout'; echo 'stderr' >&2; exit 7"],
            streamOutput: false
        )
        
        #expect(result.exitCode == 7)
        #expect(result.stdout.contains("stdout"))
        #expect(result.stderr.contains("stderr"))
        #expect(result.isSuccess == false)
    }
    
    @Test("ExecutionResult correctly stores exit code")
    func testExecutionResultStoresExitCode() {
        let result = ExecutionResult(
            exitCode: 65,
            stdout: "build output",
            stderr: "build error"
        )
        
        #expect(result.exitCode == 65)
        #expect(result.isSuccess == false)
    }
    
    @Test("ExecutionResult isSuccess computed property works correctly")
    func testIsSuccessProperty() {
        let successResult = ExecutionResult(exitCode: 0, stdout: "", stderr: "")
        #expect(successResult.isSuccess == true)
        
        let failureResult1 = ExecutionResult(exitCode: 1, stdout: "", stderr: "")
        #expect(failureResult1.isSuccess == false)
        
        let failureResult65 = ExecutionResult(exitCode: 65, stdout: "", stderr: "")
        #expect(failureResult65.isSuccess == false)
        
        let failureResult255 = ExecutionResult(exitCode: 255, stdout: "", stderr: "")
        #expect(failureResult255.isSuccess == false)
    }
    
    // MARK: - Edge Cases
    
    @Test("Large exit codes are preserved")
    func testLargeExitCodesPreserved() async throws {
        // Test with exit code 127 (command not found)
        let result = try await runner.run(
            executable: "sh",
            arguments: ["-c", "exit 127"],
            streamOutput: false
        )
        
        #expect(result.exitCode == 127)
    }
    
    @Test("Exit code 65 (common xcodebuild failure) is preserved")
    func testXcodeBuildCommonExitCode() async throws {
        // Simulate xcodebuild's common failure exit code
        let result = try await runner.run(
            executable: "sh",
            arguments: ["-c", "exit 65"],
            streamOutput: false
        )
        
        #expect(result.exitCode == 65)
        #expect(result.isSuccess == false)
    }
}
