import Testing

@testable import xcode_cli

@Suite("ProcessRunner Tests")
struct ProcessRunnerTests {
    let runner = ProcessRunner()
    
    @Test("Successful execution returns exit code 0")
    func testSuccessfulExecution() async throws {
        let result = try await runner.run(
            executable: "echo",
            arguments: ["Hello, World!"],
            streamOutput: false
        )
        
        #expect(result.exitCode == 0)
        #expect(result.isSuccess == true)
        #expect(result.stdout.contains("Hello, World!"))
    }
    
    @Test("Failed execution returns non-zero exit code")
    func testFailedExecution() async throws {
        let result = try await runner.run(
            executable: "ls",
            arguments: ["/nonexistent/directory/that/does/not/exist"],
            streamOutput: false
        )
        
        #expect(result.exitCode != 0)
        #expect(result.isSuccess == false)
    }
    
    @Test("Stdout capture works correctly")
    func testStdoutCapture() async throws {
        let testString = "Test output message"
        let result = try await runner.run(
            executable: "echo",
            arguments: [testString],
            streamOutput: false
        )
        
        #expect(result.exitCode == 0)
        #expect(result.stdout.contains(testString))
    }
    
    @Test("Stderr capture works correctly")
    func testStderrCapture() async throws {
        // Use ls on non-existent path to generate stderr
        let result = try await runner.run(
            executable: "ls",
            arguments: ["/nonexistent/path"],
            streamOutput: false
        )
        
        #expect(result.exitCode != 0)
        #expect(!result.stderr.isEmpty)
    }
    
    @Test("Stream output mode works")
    func testStreamOutputMode() async throws {
        let result = try await runner.run(
            executable: "echo",
            arguments: ["Streaming test"],
            streamOutput: true
        )
        
        #expect(result.exitCode == 0)
    }
    
    @Test("Multiple arguments are passed correctly")
    func testMultipleArguments() async throws {
        let result = try await runner.run(
            executable: "echo",
            arguments: ["arg1", "arg2", "arg3"],
            streamOutput: false
        )
        
        #expect(result.exitCode == 0)
        #expect(result.stdout.contains("arg1"))
        #expect(result.stdout.contains("arg2"))
        #expect(result.stdout.contains("arg3"))
    }
    
    @Test("Empty arguments work")
    func testEmptyArguments() async throws {
        let result = try await runner.run(
            executable: "pwd",
            arguments: [],
            streamOutput: false
        )
        
        #expect(result.exitCode == 0)
        #expect(!result.stdout.isEmpty)
    }
}
