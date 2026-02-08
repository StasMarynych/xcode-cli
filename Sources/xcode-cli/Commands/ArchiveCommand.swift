import ArgumentParser
import Foundation

struct ArchiveCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "archive",
        abstract: "Create an archive of an Xcode project or workspace"
    )
    
    @Option(name: .long, help: "Path to App Spec YAML file")
    var spec: String?
    
    @Option(name: .long, help: "Project file path (.xcodeproj)")
    var project: String?
    
    @Option(name: .long, help: "Workspace file path (.xcworkspace)")
    var workspace: String?
    
    @Option(name: [.short, .long], help: "Scheme name")
    var scheme: String?
    
    @Option(name: [.short, .long], help: "Build configuration (Debug, Release, etc.)")
    var configuration: String?
    
    @Option(name: [.short, .long], help: "Destination (e.g., 'generic/platform=iOS')")
    var destination: String?
    
    @Option(name: .long, help: "Archive output path")
    var archivePath: String?
    
    @Option(name: .long, help: "Code signing identity")
    var signingIdentity: String?
    
    @Option(name: .long, help: "Code signing style (automatic or manual)")
    var signingStyle: String?
    
    @Option(name: .long, help: "Provisioning profile UUID")
    var provisioningProfileUUID: String?
    
    @Option(name: .long, help: "Provisioning profile name")
    var provisioningProfileName: String?
    
    @Option(name: .long, help: "Provisioning profile path")
    var provisioningProfilePath: String?
    
    @Option(name: .long, help: "Development team ID")
    var teamID: String?
    
    @Option(name: .long, help: "Derived data path")
    var derivedDataPath: String?
    
    @Flag(name: .long, help: "Enable verbose output")
    var verbose: Bool = false
    
    func run() async throws {
        let flags = CommandFlags(
            spec: spec,
            project: project,
            workspace: workspace,
            scheme: scheme,
            configuration: configuration,
            destination: destination,
            signingIdentity: signingIdentity,
            signingStyle: signingStyle,
            provisioningProfileUUID: provisioningProfileUUID,
            provisioningProfileName: provisioningProfileName,
            provisioningProfilePath: provisioningProfilePath,
            teamID: teamID,
            archivePath: archivePath,
            derivedDataPath: derivedDataPath
        )
        
        let appSpec = try loadAppSpec(from: spec)
        
        let merger = ConfigurationMerger()
        let config: Configuration
        
        do {
            config = try merger.merge(spec: appSpec, flags: flags)
        } catch let error as MergerError {
            throw CLIError.configurationError(error.toConfigurationError())
        } catch {
            throw CLIError.configurationError(
                ConfigurationError.mergerError(message: error.localizedDescription)
            )
        }
        
        let executor = CommandExecutor(processRunner: ProcessRunner())
        
        do {
            let result = try await executor.executeArchive(config: config)
            
            if !result.isSuccess {
                throw CLIError.archiveError(
                    ArchiveError.xcodebuildError(exitCode: result.exitCode, stderr: result.stderr)
                )
            }
        } catch let error as CLIError {
            throw error
        } catch {
            throw CLIError.archiveError(
                ArchiveError.archiveFailed(message: error.localizedDescription)
            )
        }
    }
    
    private func loadAppSpec(from path: String?) throws -> AppSpec? {
        guard let specPath = path else {
            return nil
        }
        
        let url = URL(fileURLWithPath: specPath)
        let parser = YAMLParser()
        
        do {
            let spec = try parser.parse(fileURL: url)
            let validator = ConfigurationValidator()
            try validator.validate(spec)
            
            return spec
        } catch let error as YAMLParserError {
            throw CLIError.configurationError(
                error.toConfigurationError()
            )
        } catch let error as ValidationError {
            throw CLIError.configurationError(
                error.toConfigurationError()
            )
        } catch {
            throw CLIError.configurationError(
                ConfigurationError.mergerError(message: error.localizedDescription)
            )
        }
    }
}
