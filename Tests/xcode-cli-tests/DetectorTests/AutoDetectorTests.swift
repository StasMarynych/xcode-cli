import Testing
@testable import xcode_cli

final class MockFileManager: FileManagerProtocol {
    var files: [String] = []

    func contentsOfDirectory(atPath path: String) throws -> [String] {
        files
    }
}

final class MockSchemeListService: SchemeListServiceProtocol {
    var schemes: [String] = []
    var shouldThrow: Error?

    func listSchemes(for reference: ProjectReference) async throws -> [String] {
        if let error = shouldThrow { throw error }
        return schemes
    }
}

@Suite("Auto Detector Tests")
struct AutoDetectorTests {

    @Test("Single workspace is detected")
    func singleWorkspaceDetection() throws {
        var detector = AutoDetector()
        let mockFM = MockFileManager()
        mockFM.files = ["MyApp.xcworkspace"]
        detector.fileManager = mockFM
        let result = try detector.detectProjectOrWorkspace(in: "/tmp")
        #expect(result == .workspace(path: "/tmp/MyApp.xcworkspace"))
    }

    @Test("Single project is detected")
    func singleProjectDetection() throws {
        var detector = AutoDetector()
        let mockFM = MockFileManager()
        mockFM.files = ["MyApp.xcodeproj"]
        detector.fileManager = mockFM
        let result = try detector.detectProjectOrWorkspace(in: "/tmp")
        #expect(result == .project(path: "/tmp/MyApp.xcodeproj"))
    }

    @Test("Multiple files throws multipleProjectsFound")
    func multipleFilesError() throws {
        var detector = AutoDetector()
        let mockFM = MockFileManager()
        mockFM.files = ["App1.xcodeproj", "App2.xcodeproj"]
        detector.fileManager = mockFM
        #expect(throws: AutoDetectionError.self) {
            try detector.detectProjectOrWorkspace(in: "/tmp")
        }
    }

    @Test("No files throws noProjectFound")
    func noFilesError() throws {
        var detector = AutoDetector()
        let mockFM = MockFileManager()
        mockFM.files = []
        detector.fileManager = mockFM
        #expect(throws: AutoDetectionError.noProjectFound) {
            try detector.detectProjectOrWorkspace(in: "/tmp")
        }
    }

    @Test("Single scheme is detected")
    func singleSchemeDetection() async throws {
        var detector = AutoDetector()
        let mockRunner = MockSchemeListService()
        mockRunner.schemes = ["MyApp"]
        detector.schemeListService = mockRunner
        let result = try await detector.detectScheme(for: .project(path: "/tmp/MyApp.xcodeproj"))
        #expect(result == "MyApp")
    }

    @Test("Multiple schemes throws multipleSchemesFound")
    func multipleSchemesError() async throws {
        var detector = AutoDetector()
        let mockRunner = MockSchemeListService()
        mockRunner.schemes = ["MyApp", "MyAppTests"]
        detector.schemeListService = mockRunner
        await #expect(throws: AutoDetectionError.self) {
            try await detector.detectScheme(for: .project(path: "/tmp/MyApp.xcodeproj"))
        }
    }

    @Test("No schemes throws noSchemeFound")
    func noSchemeError() async throws {
        var detector = AutoDetector()
        let mockRunner = MockSchemeListService()
        mockRunner.schemes = []
        detector.schemeListService = mockRunner
        await #expect(throws: AutoDetectionError.noSchemeFound) {
            try await detector.detectScheme(for: .project(path: "/tmp/MyApp.xcodeproj"))
        }
    }
}
