import Foundation
import Testing

@testable import xcode_cli

@Suite("Flag Override Tests")
struct FlagOverrideTests {
    
    let merger = ConfigurationMerger()
    
    @Test("Flag override priority for project path")
    func flagOverridePriorityProjectPath() throws {
        let spec = AppSpec(
            projectPath: "SpecProject.xcodeproj",
            scheme: "SpecScheme"
        )
        
        let flags = CommandFlags(
            project: "FlagProject.xcodeproj",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.projectPath == "FlagProject.xcodeproj")
        #expect(config.workspacePath == nil)
    }
    
    @Test("Flag override priority for workspace path")
    func flagOverridePriorityWorkspacePath() throws {
        let spec = AppSpec(
            workspacePath: "SpecWorkspace.xcworkspace",
            scheme: "SpecScheme"
        )
        
        let flags = CommandFlags(
            workspace: "FlagWorkspace.xcworkspace",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.workspacePath == "FlagWorkspace.xcworkspace")
        #expect(config.projectPath == nil)
    }
    
    @Test("Flag override priority for scheme")
    func flagOverridePriorityScheme() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "SpecScheme"
        )
        
        let flags = CommandFlags(
            scheme: "FlagScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.scheme == "FlagScheme")
    }
    
    @Test("Flag override priority for build configuration")
    func flagOverridePriorityBuildConfiguration() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Debug"
        )
        
        let flags = CommandFlags(
            configuration: "Release",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.buildConfiguration == "Release")
    }
    
    @Test("Flag override priority for signing identity")
    func flagOverridePrioritySigningIdentity() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                identity: "SpecIdentity"
            )
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            signingIdentity: "FlagIdentity"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.signing?.identity == "FlagIdentity")
    }
    
    @Test("Flag override priority for team ID")
    func flagOverridePriorityTeamID() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                teamID: "SPEC123"
            )
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            teamID: "FLAG456"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.signing?.teamID == "FLAG456")
    }
    
    @Test("Flag override priority for signing style")
    func flagOverridePrioritySigningStyle() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                style: .automatic
            )
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            signingStyle: "manual"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.signing?.style == .manual)
    }
    
    @Test("Flag override priority for provisioning profile UUID")
    func flagOverridePriorityProvisioningProfileUUID() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(uuid: "spec-uuid")
            )
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            provisioningProfileUUID: "flag-uuid"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.signing?.provisioningProfile?.uuid == "flag-uuid")
    }
    
    @Test("Flag override priority for provisioning profile name")
    func flagOverridePriorityProvisioningProfileName() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(name: "SpecProfile")
            )
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            provisioningProfileName: "FlagProfile"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.signing?.provisioningProfile?.name == "FlagProfile")
    }
    
    @Test("Flag override priority for provisioning profile path")
    func flagOverridePriorityProvisioningProfilePath() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(path: "/spec/path.mobileprovision")
            )
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            provisioningProfilePath: "/flag/path.mobileprovision"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.signing?.provisioningProfile?.path == "/flag/path.mobileprovision")
    }
    
    @Test("Flag override priority for test targets")
    func flagOverridePriorityTestTargets() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            testTargets: ["SpecTest1", "SpecTest2"]
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            testTargets: ["FlagTest1", "FlagTest2", "FlagTest3"]
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.testTargets == ["FlagTest1", "FlagTest2", "FlagTest3"])
    }
    
    @Test("Flag override priority for archive path")
    func flagOverridePriorityArchivePath() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            archivePath: "/spec/archive.xcarchive"
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            archivePath: "/flag/archive.xcarchive"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.archivePath == "/flag/archive.xcarchive")
    }
    
    @Test("Flag override priority for export path")
    func flagOverridePriorityExportPath() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            exportPath: "/spec/export"
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            exportPath: "/flag/export"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.exportPath == "/flag/export")
    }
    
    @Test("Flag override priority for export method")
    func flagOverridePriorityExportMethod() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            exportMethod: .development
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            exportMethod: "app-store"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.exportMethod == ExportMethod.appStore)
    }
    
    @Test("Flag override priority for export options plist")
    func flagOverridePriorityExportOptionsPlist() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            exportOptionsPlist: "/spec/ExportOptions.plist"
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            exportOptionsPlist: "/flag/ExportOptions.plist"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.exportOptionsPlist == "/flag/ExportOptions.plist")
    }
    
    @Test("Flag override priority for derived data path")
    func flagOverridePriorityDerivedDataPath() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildOutputPath: "/spec/DerivedData"
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            derivedDataPath: "/flag/DerivedData"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.buildOutputPath == "/flag/DerivedData")
    }
    
    @Test("Flag override priority for parallel testing")
    func flagOverridePriorityParallelTesting() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            parallelTesting: false
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            parallelTesting: true
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.parallelTesting == true)
    }
    
    @Test("Flag override priority for parallel testing workers")
    func flagOverridePriorityParallelTestingWorkers() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            parallelTestingWorkers: 4
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator",
            parallelTestingWorkers: 8
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.parallelTestingWorkers == 8)
    }
    
    @Test("Flag override priority for multiple fields overridden")
    func flagOverridePriorityMultipleFieldsOverridden() throws {
        let spec = AppSpec(
            projectPath: "SpecProject.xcodeproj",
            scheme: "SpecScheme",
            buildConfiguration: "Debug",
            signing: SigningConfiguration(
                style: .automatic,
                identity: "SpecIdentity",
                teamID: "SPEC123"
            ),
            testTargets: ["SpecTest"],
            archivePath: "/spec/archive.xcarchive",
            parallelTesting: false
        )
        
        let flags = CommandFlags(
            project: "FlagProject.xcodeproj",
            scheme: "FlagScheme",
            configuration: "Release",
            destination: "platform=iOS Simulator",
            signingIdentity: "FlagIdentity",
            signingStyle: "manual",
            teamID: "FLAG456",
            archivePath: "/flag/archive.xcarchive",
            testTargets: ["FlagTest1", "FlagTest2"],
            parallelTesting: true
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.projectPath == "FlagProject.xcodeproj")
        #expect(config.scheme == "FlagScheme")
        #expect(config.buildConfiguration == "Release")
        #expect(config.signing?.identity == "FlagIdentity")
        #expect(config.signing?.style == .manual)
        #expect(config.signing?.teamID == "FLAG456")
        #expect(config.testTargets == ["FlagTest1", "FlagTest2"])
        #expect(config.archivePath == "/flag/archive.xcarchive")
        #expect(config.parallelTesting == true)
    }
    
    @Test("Flag override priority uses spec when flag not provided")
    func flagOverridePriorityFlagNotProvidedUsesSpec() throws {
        let spec = AppSpec(
            projectPath: "SpecProject.xcodeproj",
            scheme: "SpecScheme",
            buildConfiguration: "Debug",
            signing: SigningConfiguration(
                identity: "SpecIdentity",
                teamID: "SPEC123"
            ),
            testTargets: ["SpecTest"],
            archivePath: "/spec/archive.xcarchive"
        )
        
        let flags = CommandFlags(
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.projectPath == "SpecProject.xcodeproj")
        #expect(config.scheme == "SpecScheme")
        #expect(config.buildConfiguration == "Debug")
        #expect(config.signing?.identity == "SpecIdentity")
        #expect(config.signing?.teamID == "SPEC123")
        #expect(config.testTargets == ["SpecTest"])
        #expect(config.archivePath == "/spec/archive.xcarchive")
    }
}
