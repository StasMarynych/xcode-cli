import ArgumentParser
import Foundation

struct ArchiveCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "archive",
        abstract: "Create an archive of an Xcode project or workspace"
    )

    @Option(name: .long, help: "Path to App Spec YAML file")
    var spec: String?

    @Option(name: [.short, .long], help: "Scheme name")
    var scheme: String?

    @Option(name: [.short, .long], help: "Build configuration (Debug, Release, etc.)")
    var configuration: String?

    @Option(name: .long, help: "Archive output path")
    var archivePath: String?

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
                scheme: scheme,
                configuration: configuration,
                signingIdentity: signingIdentity,
                signingStyle: signingStyle,
                provisioningProfilePath: provisioningProfile,
                teamID: teamID,
                archivePath: archivePath,
                derivedDataPath: derivedDataPath
            )
        )

        logCommandContext(config, command: "Archive")

        let runner: ProcessRunnerProtocol = if let formatter {
            FormattingProcessRunner(formatterPath: formatter)
        } else {
            ProcessRunner()
        }

        let executor = CommandExecutor(processRunner: runner)
        let start = Date()
        let result = try await executor.executeArchive(config: config)
        let duration = Date().timeIntervalSince(start)

        logSeparator()
        logSummary(steps: [("archive", duration, result.isSuccess)])

        if !result.isSuccess {
            throw CLIError.archiveError(.xcodebuildError(
                exitCode: result.exitCode,
                stderr: result.stderr
            ))
        }
    }
}
