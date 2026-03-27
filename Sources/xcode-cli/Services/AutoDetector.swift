import Foundation

protocol FileManagerProtocol {
    func contentsOfDirectory(atPath path: String) throws -> [String]
}

protocol AutoDetectorProtocol {
    func detectProjectOrWorkspace(in directory: String) throws -> ProjectReference
    func detectScheme(for reference: ProjectReference) async throws -> String
}

extension FileManager: FileManagerProtocol {}

struct AutoDetector: AutoDetectorProtocol {
    var fileManager: FileManagerProtocol = FileManager.default
    var schemeListService: SchemeListServiceProtocol = XcodebuildSchemeListService()

    func detectProjectOrWorkspace(in directory: String) throws -> ProjectReference {
        let contents = try self.fileManager.contentsOfDirectory(atPath: directory)

        let workspaces = contents.filter { $0.hasSuffix(".xcworkspace") }
        let projects = contents.filter { $0.hasSuffix(".xcodeproj") }

        let allFound = workspaces + projects

        if allFound.count > 1 {
            let paths = allFound.map { "\(directory)/\($0)" }
            throw AutoDetectionError.multipleProjectsFound(paths)
        }

        if let workspace = workspaces.first {
            return .workspace(path: "\(directory)/\(workspace)")
        }

        if let project = projects.first {
            return .project(path: "\(directory)/\(project)")
        }

        throw AutoDetectionError.noProjectFound
    }

    func detectScheme(for reference: ProjectReference) async throws -> String {
        let schemes = try await self.schemeListService.listSchemes(for: reference)

        if schemes.count > 1 {
            throw AutoDetectionError.multipleSchemesFound(schemes)
        }

        guard let scheme = schemes.first else {
            throw AutoDetectionError.noSchemeFound
        }

        return scheme
    }
}
