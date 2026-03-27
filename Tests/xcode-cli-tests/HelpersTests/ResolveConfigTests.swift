import Foundation
import Testing
@testable import xcode_cli

@Suite("Resolve Config Tests")
struct ResolveConfigTests {

    @Test("Flags with project and scheme resolve correctly")
    func flagsProvidesProjectAndScheme() async throws {
        let config = try await resolveConfig(
            spec: nil,
            flags: CommandFlags(
                project: "/tmp/MyApp.xcodeproj",
                scheme: "MyApp"
            )
        )
        #expect(config.scheme == "MyApp")
        #expect(config.projectPath == "/tmp/MyApp.xcodeproj")
    }

    @Test("Flags with workspace and scheme resolve correctly")
    func flagsProvidesWorkspaceAndScheme() async throws {
        let config = try await resolveConfig(
            spec: nil,
            flags: CommandFlags(
                workspace: "/tmp/MyApp.xcworkspace",
                scheme: "MyApp"
            )
        )
        #expect(config.scheme == "MyApp")
        #expect(config.workspacePath == "/tmp/MyApp.xcworkspace")
    }

    @Test("Auto-detection triggered when no project or workspace provided")
    func autoDetectionTriggeredWhenNeitherSpecNorFlagsProvideProject() async throws {
        let emptyDir = NSTemporaryDirectory() + UUID().uuidString
        try? FileManager.default.createDirectory(atPath: emptyDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: emptyDir) }

        await #expect(throws: CLIError.self) {
            try await resolveConfig(spec: nil, flags: CommandFlags(), directory: emptyDir)
        }
    }
}
