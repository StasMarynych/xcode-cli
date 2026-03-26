import Foundation

@testable import xcode_cli

class MockSimulatorControllerForTests: SimulatorControllerProtocol {
    var devices: [SimulatorDevice]
    var launchResult: LaunchResult
    
    var getDeviceCalled = false
    var bootCalled = false
    var installAppCalled = false
    var launchAppCalled = false
    var launchAppWaitForDebugger: Bool?
    
    var shouldFailBoot = false
    var shouldFailInstall = false
    var shouldFailLaunch = false
    
    init(
        devices: [SimulatorDevice],
        launchResult: LaunchResult,
        shouldFailBoot: Bool = false,
        shouldFailInstall: Bool = false,
        shouldFailLaunch: Bool = false
    ) {
        self.devices = devices
        self.launchResult = launchResult
        self.shouldFailBoot = shouldFailBoot
        self.shouldFailInstall = shouldFailInstall
        self.shouldFailLaunch = shouldFailLaunch
    }
    
    func listDevices() async throws -> [SimulatorDevice] {
        return devices
    }
    
    func boot(deviceID: String, launchSimulatorApp: Bool) async throws {
        bootCalled = true
        
        if shouldFailBoot {
            throw SimulatorError.bootFailed(deviceID: deviceID, reason: "Mock boot failure")
        }
        
        if let index = devices.firstIndex(where: { $0.udid == deviceID || $0.name == deviceID }) {
            devices[index] = SimulatorDevice(
                udid: devices[index].udid,
                name: devices[index].name,
                state: .booted,
                runtime: devices[index].runtime
            )
        }
    }
    
    func shutdown(deviceID: String) async throws {}
    
    func getDevice(by id: String) async throws -> SimulatorDevice? {
        getDeviceCalled = true
        return devices.first { $0.name == id } ?? devices.first { $0.udid == id }
    }
    
    func installApp(deviceID: String, appPath: String) async throws {
        installAppCalled = true
        
        if shouldFailInstall {
            throw SimulatorError.installFailed(
                deviceID: deviceID,
                appPath: appPath,
                reason: "Mock install failure"
            )
        }
    }
    
    func launchApp(
        deviceID: String,
        bundleID: String,
        waitForDebugger: Bool
    ) async throws -> LaunchResult {
        launchAppCalled = true
        launchAppWaitForDebugger = waitForDebugger
        
        if shouldFailLaunch {
            throw SimulatorError.launchFailed(
                deviceID: deviceID,
                bundleID: bundleID,
                reason: "Mock launch failure"
            )
        }
        
        return launchResult
    }
    
    func terminateApp(deviceID: String, bundleID: String) async throws {}
}
