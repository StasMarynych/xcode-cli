import Testing

@testable import xcode_cli

@Suite("App Launch with Debugger Wait Tests")
struct AppLaunchDebuggerWaitTests {
    
    @Test("SimulatorController launchApp includes wait-for-debugger when flag is true")
    func testLaunchAppWithDebuggerWaitTrue() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "MyApp.TestApp: 12345",
            stderr: "",
            exitCode: 0
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        let result = try await controller.launchApp(
            deviceID: "test-device-id",
            bundleID: "com.example.TestApp",
            waitForDebugger: true
        )
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("launch") == true)
        #expect(mockRunner.lastArguments?.contains("--wait-for-debugger") == true)
        #expect(mockRunner.lastArguments?.contains("test-device-id") == true)
        #expect(mockRunner.lastArguments?.contains("com.example.TestApp") == true)
        
        #expect(result.bundleID == "com.example.TestApp")
        #expect(result.processID == 12345)
    }
    
    @Test("SimulatorController launchApp excludes wait-for-debugger when flag is false")
    func testLaunchAppWithDebuggerWaitFalse() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "MyApp.TestApp: 67890",
            stderr: "",
            exitCode: 0
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        let result = try await controller.launchApp(
            deviceID: "test-device-id",
            bundleID: "com.example.TestApp",
            waitForDebugger: false
        )
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("launch") == true)
        #expect(mockRunner.lastArguments?.contains("--wait-for-debugger") == false)
        #expect(mockRunner.lastArguments?.contains("test-device-id") == true)
        #expect(mockRunner.lastArguments?.contains("com.example.TestApp") == true)
        
        #expect(result.bundleID == "com.example.TestApp")
        #expect(result.processID == 67890)
    }
    
    @Test("Run command passes waitForDebugger flag to simulator controller")
    func testRunCommandPassesDebuggerWaitFlag() async throws {
        let mockRunner = MockProcessRunner(
            responses: [
                (executable: "xcodebuild", stdout: "/path/to/MyApp.app", stderr: "", exitCode: 0),
                (executable: "PlistBuddy", stdout: "com.example.MyApp", stderr: "", exitCode: 0),
            ]
        )
        
        let mockDevice = SimulatorDevice(
            udid: "test-device-id",
            name: "iPhone 15",
            state: .booted,
            runtime: "iOS 17.0"
        )
        
        let mockLaunchResult = LaunchResult(
            processID: 12345,
            bundleID: "com.example.MyApp"
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [mockDevice],
            launchResult: mockLaunchResult
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        _ = try await executor.executeRun(config: config, waitForDebugger: true)
        
        #expect(mockSimController.launchAppWaitForDebugger == true)
    }
    
    @Test("Run command without debugger wait flag")
    func testRunCommandWithoutDebuggerWait() async throws {
        let mockRunner = MockProcessRunner(
            responses: [
                (executable: "xcodebuild", stdout: "/path/to/MyApp.app", stderr: "", exitCode: 0),
                (executable: "PlistBuddy", stdout: "com.example.MyApp", stderr: "", exitCode: 0),
            ]
        )
        
        let mockDevice = SimulatorDevice(
            udid: "test-device-id",
            name: "iPhone 15",
            state: .booted,
            runtime: "iOS 17.0"
        )
        
        let mockLaunchResult = LaunchResult(
            processID: 67890,
            bundleID: "com.example.MyApp"
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [mockDevice],
            launchResult: mockLaunchResult
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        _ = try await executor.executeRun(config: config, waitForDebugger: false)
        
        #expect(mockSimController.launchAppWaitForDebugger == false)
    }
    
    @Test("Debugger wait flag position in simctl command")
    func testDebuggerWaitFlagPosition() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "MyApp.TestApp: 12345",
            stderr: "",
            exitCode: 0
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        _ = try await controller.launchApp(
            deviceID: "test-device-id",
            bundleID: "com.example.TestApp",
            waitForDebugger: true
        )
        
        if let args = mockRunner.lastArguments,
           let waitIndex = args.firstIndex(of: "--wait-for-debugger"),
           let bundleIndex = args.firstIndex(of: "com.example.TestApp")
        {
            #expect(waitIndex < bundleIndex)
        }
    }
}
