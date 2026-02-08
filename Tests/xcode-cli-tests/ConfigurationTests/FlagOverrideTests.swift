import Foundation
import XCTest

@testable import xcode_cli

final class FlagOverrideTests: XCTestCase {
    
    var merger: ConfigurationMerger!
    
    override func setUp() {
        super.setUp()
        merger = ConfigurationMerger()
    }
    
    func testFlagOverridePriority_ProjectPath() throws {
        let spec = AppSpec(
            projectPath: "SpecProject.xcodeproj",
            scheme: "SpecScheme"
        )
        
        let flags = CommandFlags(
            project: "FlagProject.xcodeproj",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        XCTAssertEqual(config.projectPath, "FlagProject.xcodeproj")
        XCTAssertNil(config.workspacePath)
    }
    
    func testFlagOverridePriority_WorkspacePath() throws {
        let spec = AppSpec(
            workspacePath: "SpecWorkspace.xcworkspace",
            scheme: "SpecScheme"
        )
        
        let flags = CommandFlags(
            workspace: "FlagWorkspace.xcworkspace",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        XCTAssertEqual(config.workspacePath, "FlagWorkspace.xcworkspace")
        XCTAssertNil(config.projectPath)
    }
    
    func testFlagOverridePriority_Scheme() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "SpecScheme"
        )
        
        let flags = CommandFlags(
            scheme: "FlagScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: spec, flags: flags)
        
        XCTAssertEqual(config.scheme, "FlagScheme")
    }
    
    func testFlagOverridePriority_BuildConfiguration() throws {
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
        
        XCTAssertEqual(config.buildConfiguration, "Release")
    }
    
    func testFlagOverridePriority_SigningIdentity() throws {
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
        
        XCTAssertEqual(config.signing?.identity, "FlagIdentity")
    }
    
    func testFlagOverridePriority_TeamID() throws {
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
        
        XCTAssertEqual(config.signing?.teamID, "FLAG456")
    }
    
    func testFlagOverridePriority_SigningStyle() throws {
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
        
        XCTAssertEqual(config.signing?.style, .manual)
    }
    
    func testFlagOverridePriority_ProvisioningProfileUUID() throws {
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
        
        XCTAssertEqual(config.signing?.provisioningProfile?.uuid, "flag-uuid")
    }
    
    func testFlagOverridePriority_ProvisioningProfileName() throws {
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
        
        XCTAssertEqual(config.signing?.provisioningProfile?.name, "FlagProfile")
    }
    
    func testFlagOverridePriority_ProvisioningProfilePath() throws {
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
        
        XCTAssertEqual(config.signing?.provisioningProfile?.path, "/flag/path.mobileprovision")
    }
    
    func testFlagOverridePriority_TestTargets() throws {
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
        
        XCTAssertEqual(config.testTargets, ["FlagTest1", "FlagTest2", "FlagTest3"])
    }
    
    func testFlagOverridePriority_ArchivePath() throws {
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
        
        XCTAssertEqual(config.archivePath, "/flag/archive.xcarchive")
    }
    
    func testFlagOverridePriority_ExportPath() throws {
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
        
        XCTAssertEqual(config.exportPath, "/flag/export")
    }
    
    func testFlagOverridePriority_ExportMethod() throws {
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
        
        XCTAssertEqual(config.exportMethod, ExportMethod.appStore)
    }
    
    func testFlagOverridePriority_ExportOptionsPlist() throws {
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
        
        XCTAssertEqual(config.exportOptionsPlist, "/flag/ExportOptions.plist")
    }
    
    func testFlagOverridePriority_DerivedDataPath() throws {
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
        
        XCTAssertEqual(config.buildOutputPath, "/flag/DerivedData")
    }
    
    func testFlagOverridePriority_ParallelTesting() throws {
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
        
        XCTAssertEqual(config.parallelTesting, true)
    }
    
    func testFlagOverridePriority_ParallelTestingWorkers() throws {
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
        
        XCTAssertEqual(config.parallelTestingWorkers, 8)
    }
    
    func testFlagOverridePriority_MultipleFieldsOverridden() throws {
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
        
        XCTAssertEqual(config.projectPath, "FlagProject.xcodeproj")
        XCTAssertEqual(config.scheme, "FlagScheme")
        XCTAssertEqual(config.buildConfiguration, "Release")
        XCTAssertEqual(config.signing?.identity, "FlagIdentity")
        XCTAssertEqual(config.signing?.style, .manual)
        XCTAssertEqual(config.signing?.teamID, "FLAG456")
        XCTAssertEqual(config.testTargets, ["FlagTest1", "FlagTest2"])
        XCTAssertEqual(config.archivePath, "/flag/archive.xcarchive")
        XCTAssertEqual(config.parallelTesting, true)
    }
    
    func testFlagOverridePriority_FlagNotProvidedUsesSpec() throws {
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
        
        XCTAssertEqual(config.projectPath, "SpecProject.xcodeproj")
        XCTAssertEqual(config.scheme, "SpecScheme")
        XCTAssertEqual(config.buildConfiguration, "Debug")
        XCTAssertEqual(config.signing?.identity, "SpecIdentity")
        XCTAssertEqual(config.signing?.teamID, "SPEC123")
        XCTAssertEqual(config.testTargets, ["SpecTest"])
        XCTAssertEqual(config.archivePath, "/spec/archive.xcarchive")
    }
}
