import Foundation

protocol CommandExecutorProtocol {
    func executeBuild(config: Configuration) async throws -> ExecutionResult
    func executeTest(config: Configuration) async throws -> ExecutionResult
    func executeArchive(config: Configuration) async throws -> ExecutionResult
    func executeExport(archivePath: String, config: Configuration) async throws -> ExecutionResult
    func executeRun(config: Configuration, waitForDebugger: Bool) async throws -> ExecutionResult
}

enum XcodeBuildAction {
    case build
    case test
    case archive
    case exportArchive
    case run
}

struct CommandExecutor: CommandExecutorProtocol {
    private let processRunner: ProcessRunnerProtocol
    
    init(processRunner: ProcessRunnerProtocol) {
        self.processRunner = processRunner
    }
    
    func executeBuild(config: Configuration) async throws -> ExecutionResult {
        let arguments = buildXcodeBuildArguments(action: .build, config: config)
        return try await processRunner.run(
            executable: "xcodebuild",
            arguments: arguments,
            streamOutput: true
        )
    }
    
    func executeTest(config: Configuration) async throws -> ExecutionResult {
        fatalError("Not implemented yet")
    }
    
    func executeArchive(config: Configuration) async throws -> ExecutionResult {
        fatalError("Not implemented yet")
    }
    
    func executeExport(archivePath: String, config: Configuration) async throws -> ExecutionResult {
        fatalError("Not implemented yet")
    }
    
    func executeRun(config: Configuration, waitForDebugger: Bool) async throws -> ExecutionResult {
        fatalError("Not implemented yet")
    }
    
    func buildXcodeBuildArguments(action: XcodeBuildAction, config: Configuration) -> [String] {
        var arguments: [String] = []
        
        // Add project or workspace
        if let projectPath = config.projectPath {
            arguments.append("-project")
            arguments.append(projectPath)
        } else if let workspacePath = config.workspacePath {
            arguments.append("-workspace")
            arguments.append(workspacePath)
        }
        
        // Add scheme
        arguments.append("-scheme")
        arguments.append(config.scheme)
        
        // Add configuration
        arguments.append("-configuration")
        arguments.append(config.buildConfiguration)
        
        // Add destination
        arguments.append("-destination")
        arguments.append(formatDestination(config.destination))
        
        // Add action-specific arguments
        switch action {
        case .build:
            arguments.append("build")
        case .test:
            arguments.append("test")
        case .archive:
            arguments.append("archive")
        case .exportArchive:
            arguments.append("-exportArchive")
        case .run:
            arguments.append("build")
        }
        
        // Add signing parameters
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
        
        // Add derived data path
        if let buildOutputPath = config.buildOutputPath {
            arguments.append("-derivedDataPath")
            arguments.append(buildOutputPath)
        }
        
        // Add archive path for archive action
        if action == .archive, let archivePath = config.archivePath {
            arguments.append("-archivePath")
            arguments.append(archivePath)
        }
        
        // Add export path for export action
        if action == .exportArchive, let exportPath = config.exportPath {
            arguments.append("-exportPath")
            arguments.append(exportPath)
        }
        
        return arguments
    }
    
    private func formatDestination(_ destination: Destination) -> String {
        switch destination {
        case .simulator(let name, let os):
            return "platform=iOS Simulator,name=\(name),OS=\(os)"
        case .device(let name):
            return "platform=iOS,name=\(name)"
        case .generic(let platform):
            return "generic/platform=\(platform)"
        }
    }
}
