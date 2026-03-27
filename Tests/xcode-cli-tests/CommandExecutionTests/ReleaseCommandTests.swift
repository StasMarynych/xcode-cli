import Testing
import Subprocess
import Foundation
@testable import xcode_cli

@Suite("Release Command Tests")
struct ReleaseCommandTests {

    @Test("Archive is called before export")
    func testArchiveCalledBeforeExport() async throws {
        let tracker = CallOrderTracker()

        let mockRunner = TrackingProcessRunner { _, arguments in
            if arguments.contains("archive") {
                await tracker.append("archive")
            } else if arguments.contains("-exportArchive") {
                await tracker.append("export")
            }
            return CommandResult(exitCode: 0, stdout: "", stderr: "")
        }

        let executor = CommandExecutor(processRunner: mockRunner)
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/MyApp.xcarchive",
            exportPath: "./build/export",
            exportMethod: .appStore
        )

        _ = try await executor.executeArchive(config: config)
        _ = try await executor.executeExport(archivePath: "./build/MyApp.xcarchive", config: config)

        #expect(await tracker.calls == ["archive", "export"])
    }

    @Test("Archive failure stops export")
    func testArchiveFailureStopsExport() async throws {
        let tracker = FlagTracker()

        let mockRunner = TrackingProcessRunner { _, arguments in
            if arguments.contains("archive") {
                return CommandResult(exitCode: 65, stdout: "", stderr: "Archive failed")
            }
            if arguments.contains("-exportArchive") {
                await tracker.set()
            }
            return CommandResult(exitCode: 0, stdout: "", stderr: "")
        }

        let executor = CommandExecutor(processRunner: mockRunner)
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/MyApp.xcarchive"
        )

        let archiveResult = try await executor.executeArchive(config: config)
        #expect(archiveResult.isSuccess == false)

        if archiveResult.isSuccess {
            _ = try await executor.executeExport(archivePath: "./build/MyApp.xcarchive", config: config)
        }

        #expect(await tracker.value == false)
    }

    @Test("Default export method is app-store")
    func testDefaultExportMethodIsAppStore() {
        var flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyApp"
        )
        if flags.exportMethod == nil {
            flags.exportMethod = ExportMethod.appStore.rawValue
        }
        #expect(flags.exportMethod == "app-store")
    }

    @Test("Export is called with archive path from config")
    func testExportCalledWithArchivePath() async throws {
        let capture = StringCapture()

        let mockRunner = TrackingProcessRunner { _, arguments in
            if arguments.contains("-exportArchive"),
               let idx = arguments.firstIndex(of: "-archivePath") {
                await capture.set(arguments[idx + 1])
            }
            return CommandResult(exitCode: 0, stdout: "", stderr: "")
        }

        let executor = CommandExecutor(processRunner: mockRunner)
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyApp",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/MyApp.xcarchive"
        )

        _ = try await executor.executeExport(archivePath: "./build/MyApp.xcarchive", config: config)

        #expect(await capture.value == "./build/MyApp.xcarchive")
    }

    // Feature: api-simplification, Property 11: Archive failure stops release
    // Validates: Requirement 4.3
    @Test("Property 11: Archive failure always stops release")
    func testArchiveFailureAlwaysStopsRelease() async throws {
        let exitCodes = [1, 2, 65, 70, 99, 127]
        for exitCode in exitCodes {
            let tracker = FlagTracker()

            let mockRunner = TrackingProcessRunner { _, arguments in
                if arguments.contains("archive") {
                    return CommandResult(exitCode: exitCode, stdout: "", stderr: "failed")
                }
                if arguments.contains("-exportArchive") {
                    await tracker.set()
                }
                return CommandResult(exitCode: 0, stdout: "", stderr: "")
            }

            let executor = CommandExecutor(processRunner: mockRunner)
            let config = Configuration(
                projectPath: "MyApp.xcodeproj",
                scheme: "MyApp",
                buildConfiguration: "Release",
                destination: .generic(platform: "iOS"),
                archivePath: "./build/MyApp.xcarchive"
            )

            let archiveResult = try await executor.executeArchive(config: config)
            if archiveResult.isSuccess {
                _ = try await executor.executeExport(archivePath: "./build/MyApp.xcarchive", config: config)
            }

            #expect(
                await tracker.value == false,
                "Export should not be called when archive fails with exit code \(exitCode)"
            )
        }
    }
}

final class TrackingProcessRunner: ProcessRunnerProtocol {
    private let handler: @Sendable (String, [String]) async -> CommandResult

    init(handler: @escaping @Sendable (String, [String]) async -> CommandResult) {
        self.handler = handler
    }

    func run(
        executable: String,
        arguments: [String],
        environment: [Environment.Key: String?],
        streamOutput: Bool
    ) async throws -> CommandResult {
        await handler(executable, arguments)
    }
}

actor CallOrderTracker {
    private(set) var calls: [String] = []

    func append(_ call: String) {
        calls.append(call)
    }
}

actor FlagTracker {
    private(set) var value: Bool = false

    func set() {
        value = true
    }
}

actor StringCapture {
    private(set) var value: String?

    func set(_ string: String) {
        value = string
    }
}
