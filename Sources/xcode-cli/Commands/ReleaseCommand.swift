import ArgumentParser
import Foundation

struct ReleaseCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "release",
        abstract: "Archive and export an app in a single step"
    )

    @Option(name: .long, help: "Path to App Spec YAML file")
    var spec: String?

    @Option(name: [.short, .long], help: "Scheme name")
    var scheme: String?

    @Option(name: [.short, .long], help: "Build configuration (Debug, Release, etc.)")
    var configuration: String?

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

        var flags = CommandFlags(
            spec: self.spec,
            scheme: self.scheme,
            configuration: self.configuration,
            signingIdentity: self.signingIdentity,
            signingStyle: self.signingStyle,
            provisioningProfilePath: self.provisioningProfile,
            teamID: self.teamID,
            derivedDataPath: self.derivedDataPath
        )

        if flags.exportMethod == nil {
            flags.exportMethod = ExportMethod.appStore.rawValue
        }

        let config = try await resolveConfig(spec: self.spec, flags: flags)

        logCommandContext(config, command: "Release")

        let runner: ProcessRunnerProtocol = if let formatter {
            FormattingProcessRunner(formatterPath: formatter)
        } else {
            ProcessRunner()
        }

        let executor = CommandExecutor(processRunner: runner)

        let archiveStart = Date()
        let archiveResult = try await executor.executeArchive(config: config)
        let archiveDuration = Date().timeIntervalSince(archiveStart)

        guard archiveResult.isSuccess else {
            logSeparator()
            logSummary(steps: [("archive", archiveDuration, false)])
            throw CLIError.archiveError(.xcodebuildError(
                exitCode: archiveResult.exitCode,
                stderr: archiveResult.stderr
            ))
        }

        guard let archivePath = config.archivePath else {
            throw CLIError.archiveError(.invalidArchivePath(path: "Archive path not configured"))
        }

        let exportStart = Date()
        let exportResult = try await executor.executeExport(archivePath: archivePath, config: config)
        let exportDuration = Date().timeIntervalSince(exportStart)

        logSeparator()
        logSummary(steps: [
            ("archive", archiveDuration, archiveResult.isSuccess),
            ("export", exportDuration, exportResult.isSuccess)
        ])

        if !exportResult.isSuccess {
            throw CLIError.archiveError(.xcodebuildError(
                exitCode: exportResult.exitCode,
                stderr: exportResult.stderr
            ))
        }
    }
}
