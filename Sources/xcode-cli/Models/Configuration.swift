import Foundation

struct Configuration: Equatable {
    let projectPath: String?
    let workspacePath: String?
    let scheme: String
    let buildConfiguration: String
    let destination: Destination
    let signing: SigningConfiguration?
    let testTargets: [String]
    let archivePath: String?
    let exportPath: String?
    let exportMethod: ExportMethod?
    let exportOptionsPlist: String?
    let buildOutputPath: String?
    let parallelTesting: Bool
    let parallelTestingWorkers: Int?
    
    init(
        projectPath: String? = nil,
        workspacePath: String? = nil,
        scheme: String,
        buildConfiguration: String = "Release",
        destination: Destination,
        signing: SigningConfiguration? = nil,
        testTargets: [String] = [],
        archivePath: String? = nil,
        exportPath: String? = nil,
        exportMethod: ExportMethod? = nil,
        exportOptionsPlist: String? = nil,
        buildOutputPath: String? = nil,
        parallelTesting: Bool = false,
        parallelTestingWorkers: Int? = nil
    ) {
        self.projectPath = projectPath
        self.workspacePath = workspacePath
        self.scheme = scheme
        self.buildConfiguration = buildConfiguration
        self.destination = destination
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
