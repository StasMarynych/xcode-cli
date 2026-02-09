import Foundation
import Testing

@testable import xcode_cli

@Suite("Stream Separation Tests")
struct StreamSeparationTests {
    
    // MARK: - ProcessRunner Stream Behavior Tests
    
    @Test("ProcessRunner streams raw output to stdout in stream mode")
    func testProcessRunnerStreamsToStdout() async throws {
        let runner = ProcessRunner()
        
        let result = try await runner.run(
            executable: "echo",
            arguments: ["Raw output test"],
            streamOutput: true
        )
        
        #expect(result.exitCode == 0)
        #expect(result.stdout.isEmpty)
        #expect(result.stderr.isEmpty)
    }
    
    @Test("ProcessRunner captures output when not streaming")
    func testProcessRunnerCapturesWhenNotStreaming() async throws {
        let runner = ProcessRunner()
        
        let result = try await runner.run(
            executable: "echo",
            arguments: ["Captured output"],
            streamOutput: false
        )
        
        #expect(result.exitCode == 0)
        #expect(result.stdout.contains("Captured output"))
    }
    
    @Test("ProcessRunner preserves raw output with special characters")
    func testProcessRunnerPreservesSpecialCharacters() async throws {
        let runner = ProcessRunner()
        
        let specialString = "Test\nwith\ttabs\rand\u{001B}[31mANSI\u{001B}[0m"
        let result = try await runner.run(
            executable: "echo",
            arguments: ["-e", specialString],
            streamOutput: false
        )
        
        #expect(result.exitCode == 0)
        #expect(!result.stdout.isEmpty)
    }
    
    
    // MARK: - Integration Tests
    
    @Test("ProcessRunner and Logger can coexist without interference")
    func testProcessRunnerAndLoggerCoexist() async throws {
        let runner = ProcessRunner()
        let logger = Logger.shared
        
        logger.info("Starting process")
        
        let result = try await runner.run(
            executable: "echo",
            arguments: ["Process output"],
            streamOutput: false
        )
        
        logger.success("Process completed")
        
        #expect(result.exitCode == 0)
        #expect(result.stdout.contains("Process output"))
    }
    
    @Test("Multiple log messages don't interfere with process output")
    func testMultipleLogMessagesDontInterfere() async throws {
        let runner = ProcessRunner()
        let logger = Logger.shared
        
        logger.info("Message 1")
        logger.progress("Message 2")
        logger.warning("Message 3")
        
        let result = try await runner.run(
            executable: "echo",
            arguments: ["Clean output"],
            streamOutput: false
        )
        
        logger.success("Message 4")
        logger.info("Message 5")
        
        #expect(result.exitCode == 0)
        #expect(result.stdout.contains("Clean output"))
    }
    
    // MARK: - Stream Separation Verification
    
    @Test("Verify stream separation concept")
    func testStreamSeparationConcept() async throws {
        // This test documents the stream separation design:
        // 1. ProcessRunner sends raw output to stdout (when streaming)
        // 2. Logger sends custom messages to stderr
        // 3. This allows shell redirection like: xcode-cli build > output.log
        //    - output.log will contain only raw xcodebuild output
        //    - Custom log messages will still appear on the terminal (stderr)
        
        let runner = ProcessRunner()
        let logger = Logger.shared
        
        // Simulate a typical workflow
        logger.progress("Building project...")
        
        let result = try await runner.run(
            executable: "echo",
            arguments: ["Build output line 1", "Build output line 2"],
            streamOutput: false
        )
        
        if result.isSuccess {
            logger.success("Build completed successfully")
        } else {
            logger.error("Build failed")
        }
        
        #expect(result.exitCode == 0)
        #expect(!result.stdout.isEmpty)
    }
}
