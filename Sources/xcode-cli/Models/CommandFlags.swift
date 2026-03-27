import Foundation

struct CommandFlags: Equatable {
    var spec: String?
    var project: String?
    var workspace: String?
    var scheme: String?
    var configuration: String?
    var destination: String?
    var signingIdentity: String?
    var signingStyle: String?
    var provisioningProfilePath: String?
    var teamID: String?
    var archivePath: String?
    var exportPath: String?
    var exportMethod: String?
    var exportOptionsPlist: String?
    var derivedDataPath: String?
    var testTargets: [String]?
    var parallelTesting: Bool?
    var parallelTestingWorkers: Int?

    init(
        spec: String? = nil,
        project: String? = nil,
        workspace: String? = nil,
        scheme: String? = nil,
        configuration: String? = nil,
        destination: String? = nil,
        signingIdentity: String? = nil,
        signingStyle: String? = nil,
        provisioningProfilePath: String? = nil,
        teamID: String? = nil,
        archivePath: String? = nil,
        exportPath: String? = nil,
        exportMethod: String? = nil,
        exportOptionsPlist: String? = nil,
        derivedDataPath: String? = nil,
        testTargets: [String]? = nil,
        parallelTesting: Bool? = nil,
        parallelTestingWorkers: Int? = nil
    ) {
        self.spec = spec
        self.project = project
        self.workspace = workspace
        self.scheme = scheme
        self.configuration = configuration
        self.destination = destination
        self.signingIdentity = signingIdentity
        self.signingStyle = signingStyle
        self.provisioningProfilePath = provisioningProfilePath
        self.teamID = teamID
        self.archivePath = archivePath
        self.exportPath = exportPath
        self.exportMethod = exportMethod
        self.exportOptionsPlist = exportOptionsPlist
        self.derivedDataPath = derivedDataPath
        self.testTargets = testTargets
        self.parallelTesting = parallelTesting
        self.parallelTestingWorkers = parallelTestingWorkers
    }
}
