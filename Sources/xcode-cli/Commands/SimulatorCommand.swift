import ArgumentParser
import Foundation

struct SimulatorCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "simulator",
        abstract: "Manage iOS Simulators",
        subcommands: [
            ListCommand.self,
            BootCommand.self,
            ShutdownCommand.self
        ]
    )
    
    struct ListCommand: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "list",
            abstract: "List available simulators"
        )
        
        @Flag(name: .long, help: "Enable verbose output")
        var verbose: Bool = false
        
        @Flag(name: .long, help: "Suppress non-essential output")
        var quiet: Bool = false
        
        func run() async throws {
            applyVerbosity(quiet: quiet, verbose: verbose)

            let controller = SimulatorController(processRunner: ProcessRunner())

            do {
                let devices = try await controller.listDevices()

                if devices.isEmpty {
                    logInfo("No simulators found")
                    return
                }

                logSeparator(title: "Available Simulators")

                for device in devices {
                    logInfo("\(device.name) (\(device.udid))")
                    logDebug("  Runtime: \(device.runtime)  State: \(device.state.rawValue)")
                }

                logSeparator()
            } catch let error as SimulatorError {
                throw CLIError.simulatorError(error)
            } catch {
                throw CLIError.simulatorError(.commandFailed(message: error.localizedDescription))
            }
        }
    }
    
    struct BootCommand: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "boot",
            abstract: "Boot a simulator"
        )
        
        @Argument(help: "Device name or UDID")
        var device: String
        
        @Flag(name: .long, help: "Enable verbose output")
        var verbose: Bool = false
        
        @Flag(name: .long, help: "Suppress non-essential output")
        var quiet: Bool = false
        
        func run() async throws {
            applyVerbosity(quiet: quiet, verbose: verbose)

            let controller = SimulatorController(processRunner: ProcessRunner())

            do {
                if let foundDevice = try await controller.getDevice(by: device) {
                    try await controller.boot(deviceID: foundDevice.udid)
                    logSuccess("Booted simulator: \(foundDevice.name)")
                } else {
                    try await controller.boot(deviceID: device)
                    logSuccess("Booted simulator: \(device)")
                }
            } catch let error as SimulatorError {
                throw CLIError.simulatorError(error)
            } catch {
                throw CLIError.simulatorError(.commandFailed(message: error.localizedDescription))
            }
        }
    }
    
    struct ShutdownCommand: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "shutdown",
            abstract: "Shutdown a simulator"
        )
        
        @Argument(help: "Device name or UDID")
        var device: String
        
        @Flag(name: .long, help: "Enable verbose output")
        var verbose: Bool = false
        
        @Flag(name: .long, help: "Suppress non-essential output")
        var quiet: Bool = false
        
        func run() async throws {
            applyVerbosity(quiet: quiet, verbose: verbose)

            let controller = SimulatorController(processRunner: ProcessRunner())

            do {
                if let foundDevice = try await controller.getDevice(by: device) {
                    try await controller.shutdown(deviceID: foundDevice.udid)
                    logSuccess("Shutdown simulator: \(foundDevice.name)")
                } else {
                    try await controller.shutdown(deviceID: device)
                    logSuccess("Shutdown simulator: \(device)")
                }
            } catch let error as SimulatorError {
                throw CLIError.simulatorError(error)
            } catch {
                throw CLIError.simulatorError(.commandFailed(message: error.localizedDescription))
            }
        }
    }
}
