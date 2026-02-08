import Foundation
import XCTest

@testable import xcode_cli

final class FlagsOnlyExecutionTests: XCTestCase {
    
    var merger: ConfigurationMerger!
    
    override func setUp() {
        super.setUp()
        merger = ConfigurationMerger()
    }
    
    func testFlagsOnlyExecution_WithProjectAndScheme() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        XCTAssertEqual(config.projectPath, "MyApp.xcodeproj")
        XCTAssertNil(config.workspacePath)
        XCTAssertEqual(config.scheme, "MyScheme")
        XCTAssertEqual(config.buildConfiguration, "Release")
    }
    
    func testFlagsOnlyExecution_WithWorkspaceAndScheme() throws {
        let flags = CommandFlags(
            workspace: "MyApp.xcworkspace",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        XCTAssertNil(config.projectPath)
        XCTAssertEqual(config.workspacePath, "MyApp.xcworkspace")
        XCTAssertEqual(config.scheme, "MyScheme")
        XCTAssertEqual(config.buildConfiguration, "Release")
    }
    
    func testFlagsOnlyExecution_WithAllRequiredAndOptionalFields() throws {
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
        
        XCTAssertEqual(config.projectPath, "MyApp.xcodeproj")
        XCTAssertEqual(config.scheme, "MyScheme")
        XCTAssertEqual(config.buildConfiguration, "Debug")
        XCTAssertEqual(config.signing?.identity, "Apple Development")
        XCTAssertEqual(config.signing?.style, .automatic)
        XCTAssertEqual(config.signing?.teamID, "TEAM123")
        XCTAssertEqual(config.archivePath, "/path/to/archive.xcarchive")
        XCTAssertEqual(config.exportPath, "/path/to/export")
        XCTAssertEqual(config.exportMethod, .development)
        XCTAssertEqual(config.buildOutputPath, "/path/to/DerivedData")
        XCTAssertEqual(config.testTargets, ["UnitTests", "UITests"])
        XCTAssertEqual(config.parallelTesting, true)
        XCTAssertEqual(config.parallelTestingWorkers, 4)
    }
    
    func testFlagsOnlyExecution_MissingSchemeThrowsError() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            destination: "platform=iOS Simulator"
        )
        
        XCTAssertThrowsError(try merger.merge(spec: nil, flags: flags)) { error in
            guard let mergerError = error as? MergerError else {
                XCTFail("Expected MergerError but got \(type(of: error))")
                return
            }
            XCTAssertEqual(mergerError, MergerError.missingRequiredField("scheme"))
        }
    }
    
    func testFlagsOnlyExecution_MissingProjectAndWorkspaceThrowsError() throws {
        let flags = CommandFlags(
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        XCTAssertThrowsError(try merger.merge(spec: nil, flags: flags)) { error in
            guard let mergerError = error as? MergerError else {
                XCTFail("Expected MergerError but got \(type(of: error))")
                return
            }
            XCTAssertEqual(
                mergerError, MergerError.missingRequiredField("project_path or workspace_path"))
        }
    }
    
    func testFlagsOnlyExecution_DefaultBuildConfiguration() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        XCTAssertEqual(config.buildConfiguration, "Release")
    }
    
    func testFlagsOnlyExecution_DefaultParallelTesting() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        XCTAssertEqual(config.parallelTesting, false)
    }
    
    func testFlagsOnlyExecution_DefaultTestTargets() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        XCTAssertEqual(config.testTargets, [])
    }
    
    func testFlagsOnlyExecution_WithSigningConfiguration() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator",
            signingIdentity: "Apple Distribution",
            signingStyle: "manual",
            provisioningProfileUUID: "uuid-1234",
            teamID: "TEAM456"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        XCTAssertNotNil(config.signing)
        XCTAssertEqual(config.signing?.identity, "Apple Distribution")
        XCTAssertEqual(config.signing?.style, .manual)
        XCTAssertEqual(config.signing?.provisioningProfile?.uuid, "uuid-1234")
        XCTAssertEqual(config.signing?.teamID, "TEAM456")
    }
    
    func testFlagsOnlyExecution_WithoutSigningConfiguration() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator"
        )
        
        let config = try merger.merge(spec: nil, flags: flags)
        
        XCTAssertNil(config.signing)
    }
    
    func testFlagsOnlyExecution_InvalidCodeSignStyleThrowsError() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator",
            signingStyle: "invalid-style"
        )
        
        XCTAssertThrowsError(try merger.merge(spec: nil, flags: flags)) { error in
            guard let mergerError = error as? MergerError else {
                XCTFail("Expected MergerError but got \(type(of: error))")
                return
            }
            XCTAssertEqual(mergerError, MergerError.invalidCodeSignStyle("invalid-style"))
        }
    }
    
    func testFlagsOnlyExecution_InvalidExportMethodThrowsError() throws {
        let flags = CommandFlags(
            project: "MyApp.xcodeproj",
            scheme: "MyScheme",
            destination: "platform=iOS Simulator",
            exportMethod: "invalid-method"
        )
        
        XCTAssertThrowsError(try merger.merge(spec: nil, flags: flags)) { error in
            guard let mergerError = error as? MergerError else {
                XCTFail("Expected MergerError but got \(type(of: error))")
                return
            }
            XCTAssertEqual(mergerError, MergerError.invalidExportMethod("invalid-method"))
        }
    }
}
