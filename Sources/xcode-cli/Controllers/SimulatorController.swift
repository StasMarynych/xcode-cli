import Foundation

protocol SimulatorControllerProtocol {
    func listDevices() async throws -> [SimulatorDevice]
    func boot(deviceID: String) async throws
    func shutdown(deviceID: String) async throws
    func getDevice(by id: String) async throws -> SimulatorDevice?
    func installApp(deviceID: String, appPath: String) async throws
    func launchApp(deviceID: String, bundleID: String, waitForDebugger: Bool) async throws -> LaunchResult
    func terminateApp(deviceID: String, bundleID: String) async throws
}

struct SimulatorController: SimulatorControllerProtocol {
    private let processRunner: ProcessRunnerProtocol
    
    init(processRunner: ProcessRunnerProtocol = ProcessRunner()) {
        self.processRunner = processRunner
    }
    
    func listDevices() async throws -> [SimulatorDevice] {
        let result = try await processRunner.run(
            executable: "xcrun",
            arguments: ["simctl", "list", "devices", "--json"],
            streamOutput: false
        )
        
        guard result.exitCode == 0 else {
            throw SimulatorError.commandFailed(
                message: "Failed to list devices: \(result.stderr)"
            )
        }
        
        return try parseDeviceList(from: result.stdout)
    }
    
    func boot(deviceID: String) async throws {
        let device = try? await getDevice(by: deviceID)

        if let device, device.state == .booted || device.state == .booting {
            try await openSimulatorApp()
            return
        }

        let result = try await processRunner.run(
            executable: "xcrun",
            arguments: ["simctl", "boot", deviceID],
            streamOutput: false
        )

        guard result.exitCode == 0 || result.stderr.contains("current state: Booted") else {
            throw SimulatorError.bootFailed(
                deviceID: deviceID,
                reason: result.stderr
            )
        }

        try await openSimulatorApp()
    }

    func shutdown(deviceID: String) async throws {
        let device = try? await getDevice(by: deviceID)

        if let device, device.state == .shutdown {
            return
        }

        let result = try await processRunner.run(
            executable: "xcrun",
            arguments: ["simctl", "shutdown", deviceID],
            streamOutput: false
        )

        guard result.exitCode == 0 else {
            throw SimulatorError.shutdownFailed(
                deviceID: deviceID,
                reason: result.stderr
            )
        }
    }
    
    func getDevice(by id: String) async throws -> SimulatorDevice? {
        let devices = try await listDevices()
        return devices.first { $0.name == id } ?? devices.first { $0.udid == id }
    }
    
    func installApp(deviceID: String, appPath: String) async throws {
        let result = try await processRunner.run(
            executable: "xcrun",
            arguments: ["simctl", "install", deviceID, appPath],
            streamOutput: false
        )
        
        guard result.exitCode == 0 else {
            throw SimulatorError.installFailed(
                deviceID: deviceID,
                appPath: appPath,
                reason: result.stderr
            )
        }
    }
    
    func launchApp(
        deviceID: String,
        bundleID: String,
        waitForDebugger: Bool
    ) async throws -> LaunchResult {
        var arguments = ["simctl", "launch"]
        
        if waitForDebugger {
            arguments.append("--wait-for-debugger")
        }
        
        arguments.append(contentsOf: [deviceID, bundleID])
        
        let result = try await processRunner.run(
            executable: "xcrun",
            arguments: arguments,
            streamOutput: false
        )
        
        guard result.exitCode == 0 else {
            throw SimulatorError.launchFailed(
                deviceID: deviceID, bundleID: bundleID, reason: result.stderr)
        }
        
        let processID = try parseProcessID(from: result.stdout, bundleID: bundleID)
        
        return LaunchResult(processID: processID, bundleID: bundleID)
    }
    
    func terminateApp(deviceID: String, bundleID: String) async throws {
        let result = try await processRunner.run(
            executable: "xcrun",
            arguments: ["simctl", "terminate", deviceID, bundleID],
            streamOutput: false
        )
        
        guard result.exitCode == 0 else {
            throw SimulatorError.terminateFailed(
                deviceID: deviceID,
                bundleID: bundleID,
                reason: result.stderr
            )
        }
    }
    
    // MARK: - Private Helpers

    private func openSimulatorApp() async throws {
        let result = try await processRunner.run(
            executable: "open",
            arguments: ["-a", "Simulator"],
            streamOutput: false
        )

        guard result.exitCode == 0 else {
            throw SimulatorError.commandFailed(message: "Failed to open Simulator.app: \(result.stderr)")
        }
    }

    private func parseDeviceList(from json: String) throws -> [SimulatorDevice] {
        guard let data = json.data(using: .utf8) else {
            throw SimulatorError.parsingFailed(
                message: "Failed to convert JSON string to data"
            )
        }
        
        let decoder = JSONDecoder()
        let deviceList = try decoder.decode(DeviceListResponse.self, from: data)
        
        var devices: [SimulatorDevice] = []
        
        for (runtime, deviceArray) in deviceList.devices {
            for device in deviceArray {
                devices.append(
                    SimulatorDevice(
                        udid: device.udid,
                        name: device.name,
                        state: device.state,
                        runtime: runtime
                    )
                )
            }
        }
        
        return devices
    }
    
    private func parseProcessID(from output: String, bundleID: String) throws -> Int {
        // Expected format: "bundleID: processID"
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmed.split(separator: ":")
        
        guard
            components.count == 2,
            let processIDString = components.last?.trimmingCharacters(in: .whitespaces),
            let processID = Int(processIDString)
        else {
            throw SimulatorError.parsingFailed(
                message: "Failed to parse process ID from output: \(output)"
            )
        }
        
        return processID
    }
}

private struct DeviceListResponse: Codable {
    let devices: [String: [DeviceInfo]]
}

private struct DeviceInfo: Codable {
    let udid: String
    let name: String
    let state: SimulatorState
}
