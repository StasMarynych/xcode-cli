import ArgumentParser
import Foundation

struct TestCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "test",
        abstract: "Run tests for an Xcode project or workspace"
    )

    @Option(name: .long, help: "Path to App Spec YAML file")
    var spec: String?

    @Option(name: .long, help: "Path to .xcodeproj file")
    var project: String?

    @Option(name: .long, help: "Path to .xcworkspace file")
    var workspace: String?

    @Option(name: .long, help: "Scheme name")
    var scheme: String?

    @Option(name: .long, help: "Build configuration (Debug, Release, etc.)")
    var configuration: String?

    @Option(name: .long, help: "Simulator name (e.g. 'iPhone 15')")
    var simulator: String?

    @Option(name: .long, help: "Physical device name")
    var device: String?

    @Option(name: .long, help: "OS version for simulator (e.g. '17.0')")
    var os: String?

    @Option(name: .long, help: "Specific test targets to run")
    var testTargets: [String] = []

    @Flag(name: .long, help: "Enable parallel testing")
    var parallel: Bool = false

    @Option(name: .long, help: "Number of parallel testing workers")
    var parallelTestingWorkers: Int?

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
                derivedDataPath: derivedDataPath,
                testTargets: testTargets.isEmpty ? nil : testTargets,
                parallelTesting: parallel ? true : nil,
                parallelTestingWorkers: parallelTestingWorkers
            )
        )

        logCommandContext(config, command: "Test")

        let runner: ProcessRunnerProtocol = if let formatter {
            FormattingProcessRunner(formatterPath: formatter)
        } else {
            ProcessRunner()
        }

        let executor = CommandExecutor(processRunner: runner)
        let start = Date()
        let result = try await executor.executeTest(config: config)
        let duration = Date().timeIntervalSince(start)

        logSeparator()
        logSummary(steps: [("test", duration, result.isSuccess)])

        if !result.isSuccess {
            throw CLIError.testError(.xcodebuildError(
                exitCode: result.exitCode,
                stderr: result.stderr
            ))
        }
    }
}
