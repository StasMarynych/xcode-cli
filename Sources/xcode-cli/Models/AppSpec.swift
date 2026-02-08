import Foundation

public struct AppSpec: Codable, Equatable {
    public let projectPath: String?
    public let workspacePath: String?
    public let scheme: String
    public let buildConfiguration: String?
    public let signing: SigningConfiguration?
    public let testTargets: [String]?
    public let archivePath: String?
    public let exportPath: String?
    public let exportMethod: ExportMethod?
    public let exportOptionsPlist: String?
    public let buildOutputPath: String?
    public let parallelTesting: Bool?
    public let parallelTestingWorkers: Int?
    
    enum CodingKeys: String, CodingKey {
        case projectPath = "project_path"
        case workspacePath = "workspace_path"
        case scheme
        case buildConfiguration = "build_configuration"
        case signing
        case testTargets = "test_targets"
        case archivePath = "archive_path"
        case exportPath = "export_path"
        case exportMethod = "export_method"
        case exportOptionsPlist = "export_options_plist"
        case buildOutputPath = "build_output_path"
        case parallelTesting = "parallel_testing"
        case parallelTestingWorkers = "parallel_testing_workers"
    }
    
    public init(
        projectPath: String? = nil,
        workspacePath: String? = nil,
        scheme: String,
        buildConfiguration: String? = nil,
        signing: SigningConfiguration? = nil,
        testTargets: [String]? = nil,
        archivePath: String? = nil,
        exportPath: String? = nil,
        exportMethod: ExportMethod? = nil,
        exportOptionsPlist: String? = nil,
        buildOutputPath: String? = nil,
        parallelTesting: Bool? = nil,
        parallelTestingWorkers: Int? = nil
    ) {
        self.projectPath = projectPath
        self.workspacePath = workspacePath
        self.scheme = scheme
        self.buildConfiguration = buildConfiguration
        self.signing = signing
        self.testTargets = testTargets
        self.archivePath = archivePath
        self.exportPath = exportPath
        self.exportMethod = exportMethod
        self.exportOptionsPlist = exportOptionsPlist
        self.buildOutputPath = buildOutputPath
        self.parallelTesting = parallelTesting
        self.parallelTestingWorkers = parallelTestingWorkers
    }
}
