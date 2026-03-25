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

    @Flag(name: .long, help: "Suppress non-essential output")
    var quiet: Bool = false

    @Option(name: .long, help: "Path to output formatter binary (e.g. xcbeautify, xcpretty)")
    var formatter: String?

    func run() async throws {
        applyVerbosity(quiet: quiet, verbose: verbose)

        let config = try resolveConfig(spec: spec, flags: CommandFlags(
            spec: spec, project: project, workspace: workspace,
            scheme: scheme, configuration: configuration, destination: destination,
            signingIdentity: signingIdentity, signingStyle: signingStyle,
            provisioningProfileUUID: provisioningProfileUUID,
            provisioningProfileName: provisioningProfileName,
            provisioningProfilePath: provisioningProfilePath,
            teamID: teamID, archivePath: archivePath, derivedDataPath: derivedDataPath
        ))

        let pipeline = try FormatterPipeline(formatterPath: formatter)
        let executor = CommandExecutor(processRunner: ProcessRunner())

        if formatter != nil {
            logProgress("Creating archive...")
            let exitCode = try await pipeline.run(xcodebuildArgs: executor.buildXcodeBuildArguments(action: .archive, config: config))
            if exitCode == 0 {
                logSuccess("Archive created successfully")
            } else {
                logError("Archive creation failed")
                throw CLIError.archiveError(.xcodebuildError(exitCode: exitCode, stderr: ""))
            }
        } else {
            let result = try await executor.executeArchive(config: config)
            if !result.isSuccess {
                throw CLIError.archiveError(.xcodebuildError(exitCode: result.exitCode, stderr: result.stderr))
            }
        }
    }
}
