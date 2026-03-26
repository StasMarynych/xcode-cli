import ArgumentParser
import Foundation

struct BuildForTestingCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "build-for-testing",
        abstract: "Build an Xcode project or workspace for testing without running tests"
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

    @Option(name: [.short, .long], help: "Destination (e.g., 'platform=iOS Simulator,name=iPhone 15,OS=17.0')")
    var destination: String?

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

        let config = try resolveConfig(
            spec: spec,
            flags: CommandFlags(
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
                derivedDataPath: derivedDataPath
            )
        )

        logCommandContext(config, command: "Build for Testing")

        let runner: ProcessRunnerProtocol = if let formatter { 
            FormattingProcessRunner(formatterPath: formatter) 
        } else {
            ProcessRunner()
        } 

        let executor = CommandExecutor(processRunner: runner)
        let start = Date()
        let result = try await executor.executeBuildForTesting(config: config)
        let duration = Date().timeIntervalSince(start)

        logSeparator()
        logSummary(steps: [("build-for-testing", duration, result.isSuccess)])

        if !result.isSuccess {
            throw CLIError.buildError(.xcodebuildError(
                exitCode: result.exitCode,
                stderr: result.stderr
            ))
        }
    }
}
