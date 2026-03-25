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
            if quiet {
                Logger.shared.setVerbosity(.quiet)
            } else if verbose {
                Logger.shared.setVerbosity(.verbose)
            }
            
            let controller = SimulatorController(processRunner: ProcessRunner())
            
            do {
                let devices = try await controller.listDevices()
                
                if devices.isEmpty {
                    print("No simulators found")
                    return
                }
                
                print("Available Simulators:")
                print("---------------------")
                
                for device in devices {
                    print("\(device.name) (\(device.udid))")
                    print("  Runtime: \(device.runtime)")
                    print("  State: \(device.state.rawValue)")
                    print("")
                }
            } catch let error as SimulatorError {
                throw CLIError.simulatorError(error)
            } catch {
                throw CLIError.simulatorError(
                    SimulatorError.commandFailed(message: error.localizedDescription)
                )
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
            if quiet {
                Logger.shared.setVerbosity(.quiet)
            } else if verbose {
                Logger.shared.setVerbosity(.verbose)
            }
            
            let controller = SimulatorController(processRunner: ProcessRunner())
            
            do {
                if let foundDevice = try await controller.getDevice(byName: device) {
                    try await controller.boot(deviceID: foundDevice.udid)
                    print("Successfully booted simulator: \(foundDevice.name)")
                } else {
                    try await controller.boot(deviceID: device)
                    print("Successfully booted simulator: \(device)")
                }
            } catch let error as SimulatorError {
                throw CLIError.simulatorError(error)
            } catch {
                throw CLIError.simulatorError(
                    SimulatorError.commandFailed(message: error.localizedDescription)
                )
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
            if quiet {
                Logger.shared.setVerbosity(.quiet)
            } else if verbose {
                Logger.shared.setVerbosity(.verbose)
            }
            
            let controller = SimulatorController(processRunner: ProcessRunner())
            
            do {
                if let foundDevice = try await controller.getDevice(byName: device) {
                    try await controller.shutdown(deviceID: foundDevice.udid)
                    print("Successfully shutdown simulator: \(foundDevice.name)")
                } else {
                    try await controller.shutdown(deviceID: device)
                    print("Successfully shutdown simulator: \(device)")
                }
            } catch let error as SimulatorError {
                throw CLIError.simulatorError(error)
            } catch {
                throw CLIError.simulatorError(
                    SimulatorError.commandFailed(message: error.localizedDescription)
                )
            }
        }
    }
}
