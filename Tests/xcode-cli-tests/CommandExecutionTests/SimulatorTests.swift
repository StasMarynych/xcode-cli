import Testing

@testable import xcode_cli

@Suite("Simulator Tests")
struct SimulatorTests {
    let controller = SimulatorController(processRunner: MockProcessRunner())
    
    @Test("List devices parses JSON output correctly")
    func testListDevicesParsesJSON() async throws {
        let jsonOutput = """
      {
        "devices": {
          "com.apple.CoreSimulator.SimRuntime.iOS-17-0": [
            {
              "udid": "12345678-1234-1234-1234-123456789ABC",
              "name": "iPhone 15",
              "state": "Shutdown"
            },
            {
              "udid": "87654321-4321-4321-4321-CBA987654321",
              "name": "iPhone 15 Pro",
              "state": "Booted"
            }
          ],
          "com.apple.CoreSimulator.SimRuntime.iOS-16-4": [
            {
              "udid": "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE",
              "name": "iPhone 14",
              "state": "Shutdown"
            }
          ]
        }
      }
      """
        
        let mockRunner = MockProcessRunner(stdout: jsonOutput, exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        let devices = try await controller.listDevices()
        
        #expect(devices.count == 3)
        
        let iphone15 = devices.first { $0.name == "iPhone 15" }
        #expect(iphone15 != nil)
        #expect(iphone15?.udid == "12345678-1234-1234-1234-123456789ABC")
        #expect(iphone15?.state == .shutdown)
        #expect(iphone15?.runtime == "com.apple.CoreSimulator.SimRuntime.iOS-17-0")
        
        let iphone15Pro = devices.first { $0.name == "iPhone 15 Pro" }
        #expect(iphone15Pro != nil)
        #expect(iphone15Pro?.state == .booted)
        
        let iphone14 = devices.first { $0.name == "iPhone 14" }
        #expect(iphone14 != nil)
        #expect(iphone14?.runtime == "com.apple.CoreSimulator.SimRuntime.iOS-16-4")
    }
    
    @Test("List devices handles empty device list")
    func testListDevicesHandlesEmptyList() async throws {
        let jsonOutput = """
      {
        "devices": {}
      }
      """
        
        let mockRunner = MockProcessRunner(stdout: jsonOutput, exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        let devices = try await controller.listDevices()
        
        #expect(devices.isEmpty)
    }
    
    @Test("List devices throws error on command failure")
    func testListDevicesThrowsOnFailure() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "",
            stderr: "simctl error: Unable to list devices",
            exitCode: 1
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        await #expect(throws: SimulatorError.self) {
            try await controller.listDevices()
        }
    }
    
    @Test("Get device by name finds correct device")
    func testGetDevicebyFindsDevice() async throws {
        let jsonOutput = """
      {
        "devices": {
          "com.apple.CoreSimulator.SimRuntime.iOS-17-0": [
            {
              "udid": "12345678-1234-1234-1234-123456789ABC",
              "name": "iPhone 15",
              "state": "Shutdown"
            },
            {
              "udid": "87654321-4321-4321-4321-CBA987654321",
              "name": "iPhone 15 Pro",
              "state": "Booted"
            }
          ]
        }
      }
      """
        
        let mockRunner = MockProcessRunner(stdout: jsonOutput, exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        let device = try await controller.getDevice(by: "iPhone 15 Pro")
        
        #expect(device != nil)
        #expect(device?.name == "iPhone 15 Pro")
        #expect(device?.udid == "87654321-4321-4321-4321-CBA987654321")
        #expect(device?.state == .booted)
    }
    
    @Test("Get device by name returns nil for non-existent device")
    func testGetDevicebyReturnsNilForNonExistent() async throws {
        let jsonOutput = """
      {
        "devices": {
          "com.apple.CoreSimulator.SimRuntime.iOS-17-0": [
            {
              "udid": "12345678-1234-1234-1234-123456789ABC",
              "name": "iPhone 15",
              "state": "Shutdown"
            }
          ]
        }
      }
      """
        
        let mockRunner = MockProcessRunner(stdout: jsonOutput, exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        let device = try await controller.getDevice(by: "iPhone 99")
        
        #expect(device == nil)
    }
    
    @Test("Boot throws error on failure")
    func testBootThrowsErrorOnFailure() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "",
            stderr: "Unable to boot device: Device not found",
            exitCode: 1
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        await #expect(throws: SimulatorError.self) {
            try await controller.boot(deviceID: "invalid-device-id")
        }
    }
    
    @Test("Boot succeeds with valid device")
    func testBootSucceedsWithValidDevice() async throws {
        let mockRunner = MockProcessRunner(stdout: "", exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        try await controller.boot(deviceID: "12345678-1234-1234-1234-123456789ABC", launchSimulatorApp: false)
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("boot") == true)
    }
    
    @Test("Shutdown throws error on failure")
    func testShutdownThrowsErrorOnFailure() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "",
            stderr: "Unable to shutdown device: Device not found",
            exitCode: 1
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        await #expect(throws: SimulatorError.self) {
            try await controller.shutdown(deviceID: "invalid-device-id")
        }
    }
    
    @Test("Shutdown succeeds with valid device")
    func testShutdownSucceedsWithValidDevice() async throws {
        let mockRunner = MockProcessRunner(stdout: "", exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        try await controller.shutdown(deviceID: "12345678-1234-1234-1234-123456789ABC")
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("shutdown") == true)
    }
    
    @Test("Install app throws error on failure")
    func testInstallAppThrowsErrorOnFailure() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "",
            stderr: "Unable to install app: App bundle not found",
            exitCode: 1
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        await #expect(throws: SimulatorError.self) {
            try await controller.installApp(
                deviceID: "12345678-1234-1234-1234-123456789ABC",
                appPath: "/invalid/path/MyApp.app"
            )
        }
    }
    
    @Test("Install app succeeds with valid parameters")
    func testInstallAppSucceedsWithValidParameters() async throws {
        let mockRunner = MockProcessRunner(stdout: "", exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        try await controller.installApp(
            deviceID: "12345678-1234-1234-1234-123456789ABC",
            appPath: "/path/to/MyApp.app"
        )
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("install") == true)
    }
    
    @Test("Launch app throws error on failure")
    func testLaunchAppThrowsErrorOnFailure() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "",
            stderr: "Unable to launch app: App not installed",
            exitCode: 1
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        await #expect(throws: SimulatorError.self) {
            try await controller.launchApp(
                deviceID: "12345678-1234-1234-1234-123456789ABC",
                bundleID: "com.example.app",
                waitForDebugger: false
            )
        }
    }
    
    @Test("Launch app parses process ID correctly")
    func testLaunchAppParsesProcessID() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "com.example.app: 54321",
            exitCode: 0
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        let result = try await controller.launchApp(
            deviceID: "12345678-1234-1234-1234-123456789ABC",
            bundleID: "com.example.app",
            waitForDebugger: false
        )
        
        #expect(result.processID == 54321)
        #expect(result.bundleID == "com.example.app")
    }
    
    @Test("Launch app throws error on invalid process ID format")
    func testLaunchAppThrowsOnInvalidProcessIDFormat() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "invalid output format",
            exitCode: 0
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        await #expect(throws: SimulatorError.self) {
            try await controller.launchApp(
                deviceID: "12345678-1234-1234-1234-123456789ABC",
                bundleID: "com.example.app",
                waitForDebugger: false
            )
        }
    }
    
    @Test("Terminate app throws error on failure")
    func testTerminateAppThrowsErrorOnFailure() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "",
            stderr: "Unable to terminate app: App not running",
            exitCode: 1
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        await #expect(throws: SimulatorError.self) {
            try await controller.terminateApp(
                deviceID: "12345678-1234-1234-1234-123456789ABC",
                bundleID: "com.example.app"
            )
        }
    }
    
    @Test("Terminate app succeeds with valid parameters")
    func testTerminateAppSucceedsWithValidParameters() async throws {
        let mockRunner = MockProcessRunner(stdout: "", exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        try await controller.terminateApp(
            deviceID: "12345678-1234-1234-1234-123456789ABC",
            bundleID: "com.example.app"
        )
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("terminate") == true)
    }
    
    @Test("List devices handles multiple runtimes")
    func testListDevicesHandlesMultipleRuntimes() async throws {
        let jsonOutput = """
      {
        "devices": {
          "com.apple.CoreSimulator.SimRuntime.iOS-17-0": [
            {
              "udid": "11111111-1111-1111-1111-111111111111",
              "name": "iPhone 15",
              "state": "Shutdown"
            }
          ],
          "com.apple.CoreSimulator.SimRuntime.iOS-16-4": [
            {
              "udid": "22222222-2222-2222-2222-222222222222",
              "name": "iPhone 14",
              "state": "Booted"
            }
          ],
          "com.apple.CoreSimulator.SimRuntime.watchOS-10-0": [
            {
              "udid": "33333333-3333-3333-3333-333333333333",
              "name": "Apple Watch Series 9",
              "state": "Shutdown"
            }
          ]
        }
      }
      """
        
        let mockRunner = MockProcessRunner(stdout: jsonOutput, exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        let devices = try await controller.listDevices()
        
        #expect(devices.count == 3)
        
        let iosDevices = devices.filter { $0.runtime.contains("iOS") }
        #expect(iosDevices.count == 2)
        
        let watchDevices = devices.filter { $0.runtime.contains("watchOS") }
        #expect(watchDevices.count == 1)
    }
    
    @Test("List devices handles all simulator states")
    func testListDevicesHandlesAllStates() async throws {
        let jsonOutput = """
      {
        "devices": {
          "com.apple.CoreSimulator.SimRuntime.iOS-17-0": [
            {
              "udid": "11111111-1111-1111-1111-111111111111",
              "name": "Device 1",
              "state": "Shutdown"
            },
            {
              "udid": "22222222-2222-2222-2222-222222222222",
              "name": "Device 2",
              "state": "Booted"
            },
            {
              "udid": "33333333-3333-3333-3333-333333333333",
              "name": "Device 3",
              "state": "Booting"
            },
            {
              "udid": "44444444-4444-4444-4444-444444444444",
              "name": "Device 4",
              "state": "Shutting Down"
            }
          ]
        }
      }
      """
        
        let mockRunner = MockProcessRunner(stdout: jsonOutput, exitCode: 0)
        let controller = SimulatorController(processRunner: mockRunner)
        
        let devices = try await controller.listDevices()
        
        #expect(devices.count == 4)
        #expect(devices.first { $0.state == .shutdown } != nil)
        #expect(devices.first { $0.state == .booted } != nil)
        #expect(devices.first { $0.state == .booting } != nil)
        #expect(devices.first { $0.state == .shuttingDown } != nil)
    }
    
    // Feature: xcode-cli-automation, Property 10: Simulator Boot Command Construction
    @Test("Boot command with UDID generates correct arguments")
    func testBootCommandWithUDID() async throws {
        let mockRunner = MockProcessRunner()
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceID = "12345678-1234-1234-1234-123456789ABC"
        
        do {
            try await controller.boot(deviceID: deviceID)
        } catch {}
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("boot") == true)
        #expect(mockRunner.lastArguments?.contains(deviceID) == true)
    }
    
    @Test("Boot command with device name generates correct arguments")
    func testBootCommandWithDeviceName() async throws {
        let mockRunner = MockProcessRunner()
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceName = "iPhone 15 Pro"
        
        do {
            try await controller.boot(deviceID: deviceName)
        } catch {}
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("boot") == true)
        #expect(mockRunner.lastArguments?.contains(deviceName) == true)
    }
    
    @Test("Boot command with various device identifiers")
    func testBootCommandWithVariousIdentifiers() async throws {
        let deviceIdentifiers = [
            "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE",
            "iPhone 14",
            "iPad Pro (12.9-inch)",
            "Apple Watch Series 9",
            "12345678-ABCD-EFGH-IJKL-123456789012",
        ]
        
        for deviceID in deviceIdentifiers {
            let mockRunner = MockProcessRunner()
            let controller = SimulatorController(processRunner: mockRunner)
            
            do {
                try await controller.boot(deviceID: deviceID)
            } catch {}
            
            #expect(mockRunner.lastExecutable == "xcrun")
            #expect(mockRunner.lastArguments?.contains("simctl") == true)
            #expect(mockRunner.lastArguments?.contains("boot") == true)
            #expect(mockRunner.lastArguments?.contains(deviceID) == true)
        }
    }
    
    // Feature: xcode-cli-automation, Property 11: Simulator Shutdown Command Construction
    @Test("Shutdown command with UDID generates correct arguments")
    func testShutdownCommandWithUDID() async throws {
        let mockRunner = MockProcessRunner()
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceID = "87654321-4321-4321-4321-CBA987654321"
        
        do {
            try await controller.shutdown(deviceID: deviceID)
        } catch {}
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("shutdown") == true)
        #expect(mockRunner.lastArguments?.contains(deviceID) == true)
    }
    
    @Test("Shutdown command with device name generates correct arguments")
    func testShutdownCommandWithDeviceName() async throws {
        let mockRunner = MockProcessRunner()
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceName = "iPhone 15"
        
        do {
            try await controller.shutdown(deviceID: deviceName)
        } catch {}
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("shutdown") == true)
        #expect(mockRunner.lastArguments?.contains(deviceName) == true)
    }
    
    @Test("Shutdown command with various device identifiers")
    func testShutdownCommandWithVariousIdentifiers() async throws {
        let deviceIdentifiers = [
            "FFFFFFFF-AAAA-BBBB-CCCC-DDDDDDDDDDDD",
            "iPhone SE",
            "iPad mini",
            "Apple TV 4K",
            "00000000-1111-2222-3333-444444444444",
        ]
        
        for deviceID in deviceIdentifiers {
            let mockRunner = MockProcessRunner()
            let controller = SimulatorController(processRunner: mockRunner)
            
            do {
                try await controller.shutdown(deviceID: deviceID)
            } catch {}
            
            #expect(mockRunner.lastExecutable == "xcrun")
            #expect(mockRunner.lastArguments?.contains("simctl") == true)
            #expect(mockRunner.lastArguments?.contains("shutdown") == true)
            #expect(mockRunner.lastArguments?.contains(deviceID) == true)
        }
    }
    
    @Test("Boot and shutdown commands use xcrun wrapper")
    func testCommandsUseXcrunWrapper() async throws {
        let mockRunner = MockProcessRunner()
        let controller = SimulatorController(processRunner: mockRunner)
        
        do {
            try await controller.boot(deviceID: "test-device")
        } catch {}
        
        #expect(mockRunner.lastExecutable == "xcrun")
        
        do {
            try await controller.shutdown(deviceID: "test-device")
        } catch {}
        
        #expect(mockRunner.lastExecutable == "xcrun")
    }
    
    @Test("Install app command generates correct arguments")
    func testInstallAppCommandArguments() async throws {
        let mockRunner = MockProcessRunner()
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceID = "12345678-1234-1234-1234-123456789ABC"
        let appPath = "/path/to/MyApp.app"
        
        do {
            try await controller.installApp(deviceID: deviceID, appPath: appPath)
        } catch {}
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("install") == true)
        #expect(mockRunner.lastArguments?.contains(deviceID) == true)
        #expect(mockRunner.lastArguments?.contains(appPath) == true)
    }
    
    @Test("Launch app command without debugger generates correct arguments")
    func testLaunchAppCommandWithoutDebugger() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "com.example.app: 12345",
            exitCode: 0
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceID = "12345678-1234-1234-1234-123456789ABC"
        let bundleID = "com.example.app"
        
        let result = try await controller.launchApp(
            deviceID: deviceID,
            bundleID: bundleID,
            waitForDebugger: false
        )
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("launch") == true)
        #expect(mockRunner.lastArguments?.contains(deviceID) == true)
        #expect(mockRunner.lastArguments?.contains(bundleID) == true)
        #expect(mockRunner.lastArguments?.contains("--wait-for-debugger") == false)
        #expect(result.processID == 12345)
        #expect(result.bundleID == bundleID)
    }
    
    @Test("Launch app command with debugger generates correct arguments")
    func testLaunchAppCommandWithDebugger() async throws {
        let mockRunner = MockProcessRunner(
            stdout: "com.example.app: 67890",
            exitCode: 0
        )
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceID = "12345678-1234-1234-1234-123456789ABC"
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
        #expect(result.processID == 67890)
        #expect(result.bundleID == bundleID)
    }
    
    @Test("Terminate app command generates correct arguments")
    func testTerminateAppCommandArguments() async throws {
        let mockRunner = MockProcessRunner()
        let controller = SimulatorController(processRunner: mockRunner)
        
        let deviceID = "12345678-1234-1234-1234-123456789ABC"
        let bundleID = "com.example.app"
        
        do {
            try await controller.terminateApp(deviceID: deviceID, bundleID: bundleID)
        } catch {}
        
        #expect(mockRunner.lastExecutable == "xcrun")
        #expect(mockRunner.lastArguments?.contains("simctl") == true)
        #expect(mockRunner.lastArguments?.contains("terminate") == true)
        #expect(mockRunner.lastArguments?.contains(deviceID) == true)
        #expect(mockRunner.lastArguments?.contains(bundleID) == true)
    }
}
