import Testing

@testable import xcode_cli

@Suite("Run Command Tests")
struct RunTests {
    
    @Test("Run command with booted simulator executes build and launch")
    func testRunCommandWithBootedSimulator() async throws {
        let mockRunner = MockProcessRunner(
            stdout: """
        ** BUILD SUCCEEDED **
        /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
        """,
            exitCode: 0
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15",
                    state: .booted,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 12345, bundleID: "com.example.MyApp")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeRun(config: config, waitForDebugger: false)
        
        #expect(
            mockRunner.lastExecutable == "xcodebuild" || mockRunner.lastExecutable == "/usr/libexec/PlistBuddy"
        )
        #expect(mockSimController.getDeviceCalled)
        #expect(mockSimController.installAppCalled)
        #expect(mockSimController.launchAppCalled)
        #expect(result.isSuccess)
        #expect(result.stdout.contains("12345"))
        #expect(result.stdout.contains("com.example.MyApp"))
    }
    
    @Test("Run command with shutdown simulator boots it first")
    func testRunCommandWithShutdownSimulator() async throws {
        let mockRunner = MockProcessRunner(
            stdout: """
        ** BUILD SUCCEEDED **
        /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
        """,
            exitCode: 0
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 14",
                    state: .shutdown,
                    runtime: "iOS 16.0"
                )
            ],
            launchResult: LaunchResult(processID: 54321, bundleID: "com.test.App")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 14", os: "16.0")
        )
        
        let result = try await executor.executeRun(config: config, waitForDebugger: false)
        
        #expect(mockSimController.bootCalled)
        #expect(mockRunner.lastExecutable != nil)
        #expect(mockSimController.installAppCalled)
        #expect(mockSimController.launchAppCalled)
        #expect(result.isSuccess)
    }
    
    @Test("Run command with wait for debugger flag passes it to launch")
    func testRunCommandWithWaitForDebugger() async throws {
        let mockRunner = MockProcessRunner(
            stdout: """
        ** BUILD SUCCEEDED **
        /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
        """,
            exitCode: 0
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15 Pro",
                    state: .booted,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 99999, bundleID: "com.example.DebugApp")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 15 Pro", os: "17.0")
        )
        
        let result = try await executor.executeRun(config: config, waitForDebugger: true)
        
        #expect(mockSimController.launchAppWaitForDebugger == true)
        #expect(result.isSuccess)
    }
    
    @Test("Run command with various simulator configurations")
    func testRunCommandWithVariousConfigurations() async throws {
        let configurations = [
            ("iPhone 15", "17.0", "com.app1.test"),
            ("iPhone 14 Pro", "16.4", "com.app2.test"),
            ("iPad Pro", "17.2", "com.app3.test"),
            ("iPhone SE", "15.0", "com.app4.test"),
        ]
        
        for (deviceName, os, bundleID) in configurations {
            let mockRunner = MockProcessRunner(
                stdout: """
          ** BUILD SUCCEEDED **
          /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
          """,
                exitCode: 0
            )
            
            let mockSimController = MockSimulatorControllerForTests(
                devices: [
                    SimulatorDevice(
                        udid: "test-udid-\(deviceName)",
                        name: deviceName,
                        state: .booted,
                        runtime: "iOS \(os)"
                    )
                ],
                launchResult: LaunchResult(processID: 12345, bundleID: bundleID)
            )
            
            let executor = CommandExecutor(
                processRunner: mockRunner,
                simulatorController: mockSimController
            )
            
            let config = Configuration(
                projectPath: "MyApp.xcodeproj",
                scheme: "MyApp",
                destination: .simulator(name: deviceName, os: os)
            )
            
            let result = try await executor.executeRun(config: config, waitForDebugger: false)
            
            #expect(mockSimController.getDeviceCalled)
            #expect(mockSimController.installAppCalled)
            #expect(mockSimController.launchAppCalled)
            #expect(result.isSuccess)
            #expect(result.stdout.contains(bundleID))
        }
    }
    
    @Test("Run command with wait-for-debugger flag includes correct simctl argument")
    func testWaitForDebuggerFlagIncludesCorrectArgument() async throws {
        let mockRunner = MockProcessRunner(
            stdout: """
        ** BUILD SUCCEEDED **
        /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
        """,
            exitCode: 0
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15",
                    state: .booted,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 12345, bundleID: "com.example.MyApp")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeRun(config: config, waitForDebugger: true)
        
        #expect(mockSimController.launchAppWaitForDebugger == true)
        #expect(result.isSuccess)
    }
    
    @Test("Run command without wait-for-debugger flag does not include debugger argument")
    func testWithoutWaitForDebuggerFlagExcludesArgument() async throws {
        let mockRunner = MockProcessRunner(
            stdout: """
        ** BUILD SUCCEEDED **
        /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
        """,
            exitCode: 0
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15",
                    state: .booted,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 12345, bundleID: "com.example.MyApp")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeRun(config: config, waitForDebugger: false)
        
        #expect(mockSimController.launchAppWaitForDebugger == false)
        #expect(result.isSuccess)
    }
    
    @Test("SimulatorController launchApp with wait-for-debugger includes correct simctl argument")
    func testSimulatorControllerLaunchWithDebugger() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "com.example.app: 12345",
            exitCode: 0
        )
        
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceID = "test-device-id"
        let bundleID = "com.example.app"
        
        let result = try await controller.launchApp(
            deviceID: deviceID,
            bundleID: bundleID,
            waitForDebugger: true
        )
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("launch") == true)
        #expect(mockRunner.lastArguments?.contains("--wait-for-debugger") == true)
        #expect(mockRunner.lastArguments?.contains(deviceID) == true)
        #expect(mockRunner.lastArguments?.contains(bundleID) == true)
        
        #expect(result.processID == 12345)
        #expect(result.bundleID == bundleID)
    }
    
    @Test("SimulatorController launchApp without wait-for-debugger excludes debugger argument")
    func testSimulatorControllerLaunchWithoutDebugger() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "com.example.app: 67890",
            exitCode: 0
        )
        
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceID = "test-device-id"
        let bundleID = "com.example.app"
        
        let result = try await controller.launchApp(
            deviceID: deviceID,
            bundleID: bundleID,
            waitForDebugger: false
        )
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("launch") == true)
        #expect(mockRunner.lastArguments?.contains("--wait-for-debugger") == false)
        #expect(mockRunner.lastArguments?.contains(deviceID) == true)
        #expect(mockRunner.lastArguments?.contains(bundleID) == true)
        
        #expect(result.processID == 67890)
        #expect(result.bundleID == bundleID)
    }
    
    @Test("Run command with device destination throws unsupported destination error")
    func testRunCommandWithDeviceDestinationThrowsError() async throws {
        let mockRunner = MockProcessRunner()
        let mockSimController = MockSimulatorControllerForTests(
            devices: [],
            launchResult: LaunchResult(processID: 0, bundleID: "")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .device(name: "My iPhone")
        )
        
        await #expect(throws: RunError.self) {
            try await executor.executeRun(config: config, waitForDebugger: false)
        }
    }
    
    @Test("Run command with generic destination throws unsupported destination error")
    func testRunCommandWithGenericDestinationThrowsError() async throws {
        let mockRunner = MockProcessRunner()
        let mockSimController = MockSimulatorControllerForTests(
            devices: [],
            launchResult: LaunchResult(processID: 0, bundleID: "")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .generic(platform: "iOS")
        )
        
        await #expect(throws: RunError.self) {
            try await executor.executeRun(config: config, waitForDebugger: false)
        }
    }
    
    @Test("Run command with non-existent simulator throws simulator not found error")
    func testRunCommandWithNonExistentSimulatorThrowsError() async throws {
        let mockRunner = MockProcessRunner()
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15",
                    state: .booted,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 0, bundleID: "")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 99", os: "99.0")
        )
        
        await #expect(throws: RunError.self) {
            try await executor.executeRun(config: config, waitForDebugger: false)
        }
    }
    
    @Test("Run command with build failure returns non-zero exit code")
    func testRunCommandWithBuildFailureReturnsNonZeroExitCode() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "** BUILD FAILED **",
            stderr: "error: Build failed",
            exitCode: 1
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15",
                    state: .booted,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 0, bundleID: "")
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeRun(config: config, waitForDebugger: false)
        
        #expect(result.exitCode != 0)
        #expect(!result.isSuccess)
    }
    
    @Test("Run command with app launch failure throws error")
    func testRunCommandWithAppLaunchFailureThrowsError() async throws {
        let mockRunner = MockProcessRunner(
            stdout: """
        ** BUILD SUCCEEDED **
        /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
        """,
            exitCode: 0
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15",
                    state: .booted,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 0, bundleID: ""),
            shouldFailLaunch: true
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        await #expect(throws: SimulatorError.self) {
            try await executor.executeRun(config: config, waitForDebugger: false)
        }
    }
    
    @Test("Run command with app install failure throws error")
    func testRunCommandWithAppInstallFailureThrowsError() async throws {
        let mockRunner = MockProcessRunner(
            stdout: """
        ** BUILD SUCCEEDED **
        /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
        """,
            exitCode: 0
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15",
                    state: .booted,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 0, bundleID: ""),
            shouldFailInstall: true
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        await #expect(throws: SimulatorError.self) {
            try await executor.executeRun(config: config, waitForDebugger: false)
        }
    }
    
    @Test("Run command with simulator boot failure throws error")
    func testRunCommandWithSimulatorBootFailureThrowsError() async throws {
        let mockRunner = MockProcessRunner(
            stdout: """
        ** BUILD SUCCEEDED **
        /Users/test/Library/Developer/Xcode/DerivedData/MyApp/Build/Products/Debug-iphonesimulator/MyApp.app
        """,
            exitCode: 0
        )
        
        let mockSimController = MockSimulatorControllerForTests(
            devices: [
                SimulatorDevice(
                    udid: "test-udid",
                    name: "iPhone 15",
                    state: .shutdown,
                    runtime: "iOS 17.0"
                )
            ],
            launchResult: LaunchResult(processID: 0, bundleID: ""),
            shouldFailBoot: true
        )
        
        let executor = CommandExecutor(
            processRunner: mockRunner,
            simulatorController: mockSimController
        )
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        await #expect(throws: SimulatorError.self) {
            try await executor.executeRun(config: config, waitForDebugger: false)
        }
    }
}
