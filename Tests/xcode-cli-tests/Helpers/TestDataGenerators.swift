import Foundation

@testable import xcode_cli

/// Generators for property-based testing of AppSpec configurations
enum AppSpecGenerator {
    static func randomWithScheme() -> AppSpec {
        let useProject = Bool.random()
        let projectPath = useProject ? randomPath(extension: "xcodeproj") : nil
        let workspacePath = useProject ? nil : randomPath(extension: "xcworkspace")

        let scheme = randomScheme()
        let buildConfiguration = Bool.random() ? randomBuildConfiguration() : nil
        let signing = randomSigning()
        let testTargets = Bool.random() ? randomTestTargets() : nil
        let archivePath = Bool.random() ? randomPath(extension: "xcarchive") : nil
        let exportPath = Bool.random() ? randomPath(extension: nil) : nil
        let exportMethod = Bool.random() ? randomExportMethod() : nil
        let exportOptionsPlist = Bool.random() ? randomPath(extension: "plist") : nil
        let buildOutputPath = Bool.random() ? randomPath(extension: nil) : nil

        let parallelTesting = Bool.random() ? Bool.random() : nil
        let parallelTestingWorkers: Int?
        if parallelTesting == true && Bool.random() {
            parallelTestingWorkers = Int.random(in: 1...16)
        } else {
            parallelTestingWorkers = nil
        }

        return AppSpec(
            projectPath: projectPath,
            workspacePath: workspacePath,
            scheme: scheme,
            buildConfiguration: buildConfiguration,
            signing: signing,
            testTargets: testTargets,
            archivePath: archivePath,
            exportPath: exportPath,
            exportMethod: exportMethod,
            exportOptionsPlist: exportOptionsPlist,
            buildOutputPath: buildOutputPath,
            parallelTesting: parallelTesting,
            parallelTestingWorkers: parallelTestingWorkers
        )
    }

    static func random() -> AppSpec {
        let useProject = Bool.random()
        let projectPath = useProject ? randomPath(extension: "xcodeproj") : nil
        let workspacePath = useProject ? nil : randomPath(extension: "xcworkspace")
        
        let scheme: String? = Bool.random() ? randomScheme() : nil
        let buildConfiguration = Bool.random() ? randomBuildConfiguration() : nil
        let signing = randomSigning()
        let testTargets = Bool.random() ? randomTestTargets() : nil
        let archivePath = Bool.random() ? randomPath(extension: "xcarchive") : nil
        let exportPath = Bool.random() ? randomPath(extension: nil) : nil
        let exportMethod = Bool.random() ? randomExportMethod() : nil
        let exportOptionsPlist = Bool.random() ? randomPath(extension: "plist") : nil
        let buildOutputPath = Bool.random() ? randomPath(extension: nil) : nil
        
        let parallelTesting = Bool.random() ? Bool.random() : nil
        let parallelTestingWorkers: Int?
        if parallelTesting == true && Bool.random() {
            parallelTestingWorkers = Int.random(in: 1...16)
        } else {
            parallelTestingWorkers = nil
        }
        
        return AppSpec(
            projectPath: projectPath,
            workspacePath: workspacePath,
            scheme: scheme,
            buildConfiguration: buildConfiguration,
            signing: signing,
            testTargets: testTargets,
            archivePath: archivePath,
            exportPath: exportPath,
            exportMethod: exportMethod,
            exportOptionsPlist: exportOptionsPlist,
            buildOutputPath: buildOutputPath,
            parallelTesting: parallelTesting,
            parallelTestingWorkers: parallelTestingWorkers
        )
    }
    
    static func randomSigning() -> SigningConfiguration? {
        guard Bool.random() else { return nil }
        
        let style = Bool.random() ? randomCodeSignStyle() : nil
        let identity = Bool.random() ? randomIdentity() : nil
        let teamID = Bool.random() ? randomTeamID() : nil
        let provisioningProfile = randomProvisioningProfile()
        
        return SigningConfiguration(
            style: style,
            identity: identity,
            teamID: teamID,
            provisioningProfile: provisioningProfile
        )
    }
    
    static func randomProvisioningProfile() -> ProvisioningProfile? {
        guard Bool.random() else { return nil }
        
        let choice = Int.random(in: 0...2)
        switch choice {
        case 0:
            return ProvisioningProfile(
                uuid: randomUUID(),
                name: nil,
                path: nil
            )
        case 1:
            return ProvisioningProfile(
                uuid: nil,
                name: randomProfileName(),
                path: nil
            )
        case 2:
            return ProvisioningProfile(
                uuid: nil,
                name: nil,
                path: randomPath(extension: "mobileprovision")
            )
        default:
            return nil
        }
    }
    
    // MARK: - Helper Generators
    
    private static func randomPath(extension ext: String?) -> String {
        let components = (1...Int.random(in: 1...3))
            .map { _ in randomString(length: 8) }
        let path = components.joined(separator: "/")
        
        if let ext = ext {
            return "\(path).\(ext)"
        }
        
        return path
    }
    
    private static func randomScheme() -> String {
        ["MyApp", "MyAppTests", "Production", "Debug", "Release", "Staging"]
            .randomElement()!
    }
    
    private static func randomBuildConfiguration() -> String {
        ["Debug", "Release", "Staging", "Production"]
            .randomElement()!
    }
    
    private static func randomCodeSignStyle() -> CodeSignStyle {
        Bool.random() ? .automatic : .manual
    }
    
    private static func randomExportMethod() -> ExportMethod {
        [.appStore, .adHoc, .enterprise, .development]
            .randomElement()!
    }
    
    private static func randomIdentity() -> String {
        let identities = [
            "iPhone Developer",
            "iPhone Distribution",
            "Apple Development",
            "Apple Distribution",
        ]
        return identities.randomElement()!
    }
    
    private static func randomTeamID() -> String {
        randomString(length: 10).uppercased()
    }
    
    private static func randomUUID() -> String {
        UUID().uuidString
    }
    
    private static func randomProfileName() -> String {
        [
            "iOS Team Provisioning Profile",
            "Development Profile",
            "Distribution Profile",
            "Ad Hoc Profile",
        ]
            .randomElement()!
    }
    
    private static func randomTestTargets() -> [String] {
        (0..<Int.random(in: 1...5))
            .map { _ in "\(randomString(length: 8))Tests" }
    }
    
    private static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
