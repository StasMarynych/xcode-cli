import ArgumentParser
import Foundation

struct RunCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "run",
        abstract: "Build and run the app on a simulator or device"
    )

    @Option(name: .long, help: "Path to App Spec YAML file")
    var spec: String?

    @Option(name: .long, help: "Path to .xcodeproj file")
    var project: String?

    @Option(name: .long, help: "Path to .xcworkspace file")
    var workspace: String?

    @Option(name: [.short, .long], help: "Scheme name")
    var scheme: String?

    @Option(name: [.short, .long], help: "Build configuration (Debug, Release, etc.)")
    var configuration: String?

    @Option(name: .long, help: "Simulator name (e.g. 'iPhone 15')")
    var simulator: String?

    @Option(name: .long, help: "Physical device name")
    var device: String?

    @Option(name: .long, help: "OS version for simulator (e.g. '17.0')")
    var os: String?

    @Flag(name: .long, help: "Wait for debugger to attach before launching")
    var waitForDebugger: Bool = false

    @Option(name: .long, help: "Derived data path")
    var derivedDataPath: String?

    @Option(name: .long, help: "Code signing identity")
    var signingIdentity: String?

    @Option(name: .long, help: "Code signing style (automatic or manual)")
    var signingStyle: String?

    @Option(name: .long, help: "Development team ID")
    var teamID: String?

    @Option(name: .long, help: "Provisioning profile path")
    var provisioningProfile: String?

    @Option(name: .long, help: "Path to output formatter binary (e.g. xcbeautify, xcpretty)")
    var formatter: String?

    @Flag(name: .long, help: "Enable verbose output")
    var verbose: Bool = false

    @Flag(name: .long, help: "Suppress non-essential output")
    var quiet: Bool = false

    func run() async throws {
        applyVerbosity(quiet: quiet, verbose: verbose)

        let config = try await resolveConfig(
            spec: spec,
            flags: CommandFlags(
                spec: spec,
                project: project,
                workspace: workspace,
                scheme: scheme,
                configuration: configuration,
                destination: try Destination(simulator: simulator, device: device, os: os),
                signingIdentity: signingIdentity,
                signingStyle: signingStyle,
                provisioningProfilePath: provisioningProfile,
                teamID: teamID,
                derivedDataPath: derivedDataPath
            )
        )

        logCommandContext(config, command: "Run")

        let runner: ProcessRunnerProtocol = if let formatter {
            FormattingProcessRunner(formatterPath: formatter)
        } else {
            ProcessRunner()
        }

        let executor = CommandExecutor(processRunner: runner)
        let start = Date()
        let result = try await executor.executeRun(config: config, waitForDebugger: waitForDebugger)
        let duration = Date().timeIntervalSince(start)

        logSeparator()
        logSummary(steps: [("run", duration, result.isSuccess)])

        if !result.isSuccess {
            throw CLIError.buildError(.xcodebuildError(
                exitCode: result.exitCode,
                stderr: result.stderr
            ))
        }
    }
}
