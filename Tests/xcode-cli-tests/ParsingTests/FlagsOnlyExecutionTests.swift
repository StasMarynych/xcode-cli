import Foundation
import Testing

@testable import xcode_cli

@Suite("Flags Only Execution Tests")
struct FlagsOnlyExecutionTests {
    
    let merger = ConfigurationMerger()
    
    @Test("Flags only execution with project and scheme")
    func flagsOnlyExecutionWithProjectAndScheme() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        #expect(config.projectPath == "MyApp.xcodeproj")
        #expect(config.workspacePath == nil)
        #expect(config.scheme == "MyScheme")
        #expect(config.buildConfiguration == "Release")
    }
    
    @Test("Flags only execution with workspace and scheme")
    func flagsOnlyExecutionWithWorkspaceAndScheme() throws {
        let flags = CommandFlags(
            workspace: "MyApp.xcworkspace",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        #expect(config.projectPath == nil)
        #expect(config.workspacePath == "MyApp.xcworkspace")
        #expect(config.scheme == "MyScheme")
        #expect(config.buildConfiguration == "Release")
    }
    
    @Test("Flags only execution with all required and optional fields")
    func flagsOnlyExecutionWithAllRequiredAndOptionalFields() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            configuration: "Debug",
            destination: "platform=iOS Simulator,name=iPhone 15",
            signingIdentity: "Apple Development",
            signingStyle: "automatic",
            teamID: "TEAM123",
            archivePath: "/path/to/archive.xcarchive",
            exportPath: "/path/to/export",
            exportMethod: "development",
            derivedDataPath: "/path/to/DerivedData",
            testTargets: ["UnitTests", "UITests"],
            parallelTesting: true,
            parallelTestingWorkers: 4
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        #expect(config.projectPath == "MyApp.xcodeproj")
        #expect(config.scheme == "MyScheme")
        #expect(config.buildConfiguration == "Debug")
        #expect(config.signing?.identity == "Apple Development")
        #expect(config.signing?.style == .automatic)
        #expect(config.signing?.teamID == "TEAM123")
        #expect(config.archivePath == "/path/to/archive.xcarchive")
        #expect(config.exportPath == "/path/to/export")
        #expect(config.exportMethod == .development)
        #expect(config.buildOutputPath == "/path/to/DerivedData")
        #expect(config.testTargets == ["UnitTests", "UITests"])
        #expect(config.parallelTesting == true)
        #expect(config.parallelTestingWorkers == 4)
    }
    
    @Test("Flags only execution missing scheme throws error")
    func flagsOnlyExecutionMissingSchemeThrowsError() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            destination: "platform=iOS Simulator"
        )
        
        #expect(throws: MergerError.missingRequiredField("scheme")) {
            try merger.merge(spec: nil, flags: flags)
        }
    }
    
    @Test("Flags only execution missing project and workspace throws error")
    func flagsOnlyExecutionMissingProjectAndWorkspaceThrowsError() throws {
        let flags = CommandFlags(
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        #expect(throws: MergerError.missingRequiredField("project_path or workspace_path")) {
            try merger.merge(spec: nil, flags: flags)
        }
    }
    
    @Test("Flags only execution default build configuration")
    func flagsOnlyExecutionDefaultBuildConfiguration() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        #expect(config.buildConfiguration == "Release")
    }
    
    @Test("Flags only execution default parallel testing")
    func flagsOnlyExecutionDefaultParallelTesting() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        #expect(config.parallelTesting == false)
    }
    
    @Test("Flags only execution default test targets")
    func flagsOnlyExecutionDefaultTestTargets() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        #expect(config.testTargets == [])
    }
    
    @Test("Flags only execution with signing configuration")
    func flagsOnlyExecutionWithSigningConfiguration() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator",
            signingIdentity: "Apple Distribution",
            signingStyle: "manual",
            provisioningProfilePath: "/path/to/profile.mobileprovision",
            teamID: "TEAM456"
        )

        let config = try merger.merge(spec: nil, flags: flags)

        #expect(config.signing != nil)
        #expect(config.signing?.identity == "Apple Distribution")
        #expect(config.signing?.style == .manual)
        #expect(config.signing?.provisioningProfile?.path == "/path/to/profile.mobileprovision")
        #expect(config.signing?.teamID == "TEAM456")
    }
    
    @Test("Flags only execution without signing configuration")
    func flagsOnlyExecutionWithoutSigningConfiguration() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        #expect(config.signing == nil)
    }
    
    @Test("Flags only execution invalid code sign style throws error")
    func flagsOnlyExecutionInvalidCodeSignStyleThrowsError() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator",
            signingStyle: "invalid-style"
        )
        
        #expect(throws: MergerError.invalidCodeSignStyle("invalid-style")) {
            try merger.merge(spec: nil, flags: flags)
        }
    }
    
    @Test("Flags only execution invalid export method throws error")
    func flagsOnlyExecutionInvalidExportMethodThrowsError() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator",
            exportMethod: "invalid-method"
        )
        
        #expect(throws: MergerError.invalidExportMethod("invalid-method")) {
            try merger.merge(spec: nil, flags: flags)
        }
    }
}
