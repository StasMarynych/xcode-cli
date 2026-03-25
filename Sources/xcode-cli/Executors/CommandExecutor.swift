import Foundation

protocol CommandExecutorProtocol {
    func executeBuild(config: Configuration) async throws -> CommandResult
    func executeTest(config: Configuration) async throws -> CommandResult
    func executeArchive(config: Configuration) async throws -> CommandResult
    func executeExport(archivePath: String, config: Configuration) async throws -> CommandResult
    func executeRun(config: Configuration, waitForDebugger: Bool) async throws -> CommandResult
}

enum XcodeBuildAction {
    case build
    case test
    case archive
    case exportArchive
    case run
}

enum RunError: Error, CustomStringConvertible {
    case unsupportedDestination(String)
    case simulatorNotFound(String)
    case appBundleNotFound(String)
    case bundleIDNotFound(String)
    
    var description: String {
        switch self {
        case .unsupportedDestination(let message):
            "Unsupported destination: \(message)"
        case .simulatorNotFound(let message):
            "Simulator not found: \(message)"
        case .appBundleNotFound(let message):
            "App bundle not found: \(message)"
        case .bundleIDNotFound(let message):
            "Bundle ID not found: \(message)"
        }
    }
}

struct CommandExecutor: CommandExecutorProtocol {
    private let processRunner: ProcessRunnerProtocol
    private let simulatorController: SimulatorControllerProtocol
    
    init(
        processRunner: ProcessRunnerProtocol,
        simulatorController: SimulatorControllerProtocol? = nil
    ) {
        self.processRunner = processRunner
        self.simulatorController = simulatorController ?? SimulatorController(processRunner: processRunner)
    }
    
    func executeBuild(config: Configuration) async throws -> CommandResult {
        let arguments = buildXcodeBuildArguments(action: .build, config: config)
        let result = try await processRunner.run(
            executable: "xcodebuild",
            arguments: arguments,
            environment: [
                "NSUnbufferedIO": "YES"
            ],
            streamOutput: true
        )
         
        return result
    }
    
    func executeTest(config: Configuration) async throws -> CommandResult {
        let arguments = buildXcodeBuildArguments(action: .test, config: config)
        let result = try await processRunner.run(
            executable: "xcodebuild",
            arguments: arguments,
            environment: [
                "NSUnbufferedIO": "YES"
            ],
            streamOutput: true
        )
        
        return result
    }
    
    func executeArchive(config: Configuration) async throws -> CommandResult {
        let arguments = buildXcodeBuildArguments(action: .archive, config: config)
        let result = try await processRunner.run(
            executable: "xcodebuild",
            arguments: arguments,
            environment: [
                "NSUnbufferedIO": "YES"
            ],
            streamOutput: true
        )
        
        return result
    }
    
    func executeExport(archivePath: String, config: Configuration) async throws -> CommandResult {
        let arguments = buildExportArguments(archivePath: archivePath, config: config)
        let result = try await processRunner.run(
            executable: "xcodebuild",
            arguments: arguments,
            environment: [
                "NSUnbufferedIO": "YES"
            ],
            streamOutput: true
        )
        
        return result
    }
    
    func buildExportArguments(archivePath: String, config: Configuration) -> [String] {
        var arguments: [String] = []
        
        arguments.append("-exportArchive")
        arguments.append("-archivePath")
        arguments.append(archivePath)
        
        if let exportPath = config.exportPath {
            arguments.append("-exportPath")
            arguments.append(exportPath)
        }
        
        if let exportOptionsPlist = config.exportOptionsPlist {
            arguments.append("-exportOptionsPlist")
            arguments.append(exportOptionsPlist)
        }
        
        return arguments
    }
    
    func executeRun(config: Configuration, waitForDebugger: Bool) async throws -> CommandResult {
        guard case .simulator(let name, _) = config.destination else {
            throw RunError.unsupportedDestination(
                "Run command only supports simulator destinations"
            )
        }
        
        guard let device = try await simulatorController.getDevice(by: name) else {
            throw RunError.simulatorNotFound(name)
        }
        
        if device.state != .booted {
            Logger.shared.progress("Booting simulator \(name)...")
            try await simulatorController.boot(deviceID: device.udid)
            
            var attempts = 0
            while attempts < 30 {
                let updatedDevice = try await simulatorController.getDevice(by: name)
                if updatedDevice?.state == .booted {
                    break
                }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                attempts += 1
            }
        }
        
        let buildResult = try await executeBuild(config: config)
        
        guard buildResult.isSuccess else {
            return buildResult
        }
        
        guard let appPath = extractAppBundlePath(from: buildResult.stdout) else {
            throw RunError.appBundleNotFound("Failed to extract app bundle path from build output")
        }
        
        guard let bundleID = try await extractBundleID(from: appPath) else {
            throw RunError.bundleIDNotFound("Failed to extract bundle ID from app at \(appPath)")
        }
        
        Logger.shared.progress("Installing app on simulator...")
        try await simulatorController.installApp(deviceID: device.udid, appPath: appPath)
        
        Logger.shared.progress("Launching app...")
        let launchResult = try await simulatorController.launchApp(
            deviceID: device.udid,
            bundleID: bundleID,
            waitForDebugger: waitForDebugger
        )
        
        Logger.shared.success("App launched successfully!")
        Logger.shared.info("Bundle ID: \(launchResult.bundleID)")
        Logger.shared.info("Process ID: \(launchResult.processID)")
        
        if waitForDebugger {
            Logger.shared.info("Waiting for debugger to attach...")
        }
        
        return CommandResult(
            exitCode: 0,
            stdout: "Bundle ID: \(launchResult.bundleID)\nProcess ID: \(launchResult.processID)",
            stderr: ""
        )
    }
    
    private func extractAppBundlePath(from buildOutput: String) -> String? {
        let lines = buildOutput.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains(".app") && !line.contains(".appex") {
                if let range = line.range(of: #"(/[^\s]+\.app)"#, options: .regularExpression) {
                    let path = String(line[range])
                    return path.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                }
            }
        }
        
        return nil
    }
    
    private func extractBundleID(from appPath: String) async throws -> String? {
        let infoPlistPath = "\(appPath)/Info.plist"
        
        let result = try await processRunner.run(
            executable: "/usr/libexec/PlistBuddy",
            arguments: ["-c", "Print :CFBundleIdentifier", infoPlistPath],
            streamOutput: false
        )
        
        guard result.isSuccess else {
            return nil
        }
        
        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func buildXcodeBuildArguments(action: XcodeBuildAction, config: Configuration) -> [String] {
        var arguments: [String] = []
        
        if let projectPath = config.projectPath {
            arguments.append("-project")
            arguments.append(projectPath)
        } else if let workspacePath = config.workspacePath {
            arguments.append("-workspace")
            arguments.append(workspacePath)
        }
        
        arguments.append("-scheme")
        arguments.append(config.scheme)
        
        arguments.append("-configuration")
        arguments.append(config.buildConfiguration)
        
        arguments.append("-destination")
        arguments.append(formatDestination(config.destination))
        
        switch action {
        case .build:
            arguments.append("build")
        case .test:
            arguments.append("test")
            
            if !config.testTargets.isEmpty {
                for target in config.testTargets {
                    arguments.append("-only-testing")
                    arguments.append(target)
                }
            }
            
            if config.parallelTesting {
                arguments.append("-parallel-testing-enabled")
                arguments.append("YES")
                
                if let workers = config.parallelTestingWorkers {
                    arguments.append("-parallel-testing-worker-count")
                    arguments.append("\(workers)")
                }
            }
        case .archive:
            arguments.append("archive")
        case .exportArchive:
            arguments.append("-exportArchive")
        case .run:
            arguments.append("build")
        }
        
        if let signing = config.signing {
            if let style = signing.style {
                arguments.append("CODE_SIGN_STYLE=\(style.rawValue)")
            }
            
            if let identity = signing.identity {
                arguments.append("CODE_SIGN_IDENTITY=\(identity)")
            }
            
            if let teamID = signing.teamID {
                arguments.append("DEVELOPMENT_TEAM=\(teamID)")
            }
            
            if let provisioningProfile = signing.provisioningProfile {
                if let uuid = provisioningProfile.uuid {
                    arguments.append("PROVISIONING_PROFILE=\(uuid)")
                } else if let name = provisioningProfile.name {
                    arguments.append("PROVISIONING_PROFILE_SPECIFIER=\(name)")
                } else if let path = provisioningProfile.path {
                    arguments.append("PROVISIONING_PROFILE=\(path)")
                }
            }
        }
        
        if let buildOutputPath = config.buildOutputPath {
            arguments.append("-derivedDataPath")
            arguments.append(buildOutputPath)
        }
        
        if action == .archive, let archivePath = config.archivePath {
            arguments.append("-archivePath")
            arguments.append(archivePath)
        }
        
        if action == .exportArchive, let exportPath = config.exportPath {
            arguments.append("-exportPath")
            arguments.append(exportPath)
        }
        
        return arguments
    }
    
    private func formatDestination(_ destination: Destination) -> String {
        switch destination {
        case let .simulator(name, os):
            if os == "latest" {
                return "platform=iOS Simulator,name=\(name)"
            }
            return "platform=iOS Simulator,name=\(name),OS=\(os)"
        case let .device(name):
            return "platform=iOS,name=\(name)"
        case let .generic(platform):
            return "generic/platform=\(platform)"
        }
    }
}
