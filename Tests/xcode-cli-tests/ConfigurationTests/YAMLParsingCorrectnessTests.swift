import Foundation
import XCTest

@testable import xcode_cli

final class YAMLParsingCorrectnessTests: XCTestCase {
    
    var tempDirectory: URL!
    var parser: YAMLParser!
    
    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        parser = YAMLParser()
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }
    
    func testYAMLParsingCorrectness_MinimalValidSpec() throws {
        let yamlContent = """
      project_path: "MyApp.xcodeproj"
      scheme: "MyScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(spec.projectPath, "MyApp.xcodeproj")
        XCTAssertEqual(spec.scheme, "MyScheme")
        XCTAssertNil(spec.workspacePath)
        XCTAssertNil(spec.buildConfiguration)
    }
    
    func testYAMLParsingCorrectness_FullSpec() throws {
        let yamlContent = """
      project_path: "MyApp.xcodeproj"
      scheme: "MyScheme"
      build_configuration: "Release"
      signing:
          style: "manual"
          identity: "Apple Distribution"
          team_id: "TEAM123"
          provisioning_profile:
              uuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
      test_targets:
          - "UnitTests"
          - "UITests"
      archive_path: "./build/archive.xcarchive"
      export_path: "./build"
      export_method: "app-store"
      export_options_plist: "./ExportOptions.plist"
      build_output_path: "./DerivedData"
      parallel_testing: true
      parallel_testing_workers: 4
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(spec.projectPath, "MyApp.xcodeproj")
        XCTAssertEqual(spec.scheme, "MyScheme")
        XCTAssertEqual(spec.buildConfiguration, "Release")
        XCTAssertEqual(spec.signing?.style, .manual)
        XCTAssertEqual(spec.signing?.identity, "Apple Distribution")
        XCTAssertEqual(spec.signing?.teamID, "TEAM123")
        XCTAssertEqual(spec.signing?.provisioningProfile?.uuid, "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        XCTAssertEqual(spec.testTargets, ["UnitTests", "UITests"])
        XCTAssertEqual(spec.archivePath, "./build/archive.xcarchive")
        XCTAssertEqual(spec.exportPath, "./build")
        XCTAssertEqual(spec.exportMethod, .appStore)
        XCTAssertEqual(spec.exportOptionsPlist, "./ExportOptions.plist")
        XCTAssertEqual(spec.buildOutputPath, "./DerivedData")
        XCTAssertEqual(spec.parallelTesting, true)
        XCTAssertEqual(spec.parallelTestingWorkers, 4)
    }
    
    func testYAMLParsingCorrectness_WorkspaceSpec() throws {
        let yamlContent = """
      workspace_path: "MyApp.xcworkspace"
      scheme: "MyScheme"
      build_configuration: "Debug"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertNil(spec.projectPath)
        XCTAssertEqual(spec.workspacePath, "MyApp.xcworkspace")
        XCTAssertEqual(spec.scheme, "MyScheme")
        XCTAssertEqual(spec.buildConfiguration, "Debug")
    }
    
    func testYAMLParsingCorrectness_ExportMethods() throws {
        let exportMethods = [
            ("app-store", ExportMethod.appStore),
            ("ad-hoc", ExportMethod.adHoc),
            ("enterprise", ExportMethod.enterprise),
            ("development", ExportMethod.development),
        ]
        
        for (yamlValue, expectedEnum) in exportMethods {
            let yamlContent = """
        project_path: "Test.xcodeproj"
        scheme: "TestScheme"
        export_method: "\(yamlValue)"
        """
            
            let fileURL = tempDirectory.appendingPathComponent("test-\(yamlValue).yaml")
            try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let spec = try parser.parse(fileURL: fileURL)
            
            XCTAssertEqual(spec.exportMethod, expectedEnum, "Failed to parse export method: \(yamlValue)")
        }
    }
    
    func testYAMLParsingCorrectness_CodeSignStyles() throws {
        let styles = [
            ("automatic", CodeSignStyle.automatic),
            ("manual", CodeSignStyle.manual),
        ]
        
        for (yamlValue, expectedEnum) in styles {
            let yamlContent = """
        project_path: "Test.xcodeproj"
        scheme: "TestScheme"
        signing:
            style: "\(yamlValue)"
        """
            
            let fileURL = tempDirectory.appendingPathComponent("test-\(yamlValue).yaml")
            try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            let spec = try parser.parse(fileURL: fileURL)
            
            XCTAssertEqual(
                spec.signing?.style, expectedEnum, "Failed to parse code sign style: \(yamlValue)")
        }
    }
    
    func testYAMLParsingCorrectness_ProvisioningProfileByUUID() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing:
          provisioning_profile:
              uuid: "test-uuid-1234"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(spec.signing?.provisioningProfile?.uuid, "test-uuid-1234")
        XCTAssertNil(spec.signing?.provisioningProfile?.name)
        XCTAssertNil(spec.signing?.provisioningProfile?.path)
    }
    
    func testYAMLParsingCorrectness_ProvisioningProfileByName() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing:
          provisioning_profile:
              name: "MyApp Distribution Profile"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertNil(spec.signing?.provisioningProfile?.uuid)
        XCTAssertEqual(spec.signing?.provisioningProfile?.name, "MyApp Distribution Profile")
        XCTAssertNil(spec.signing?.provisioningProfile?.path)
    }
    
    func testYAMLParsingCorrectness_ProvisioningProfileByPath() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing:
          provisioning_profile:
              path: "/path/to/profile.mobileprovision"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertNil(spec.signing?.provisioningProfile?.uuid)
        XCTAssertNil(spec.signing?.provisioningProfile?.name)
        XCTAssertEqual(spec.signing?.provisioningProfile?.path, "/path/to/profile.mobileprovision")
    }
    
    func testYAMLParsingCorrectness_TestTargets() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      test_targets:
          - "UnitTests"
          - "IntegrationTests"
          - "UITests"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(spec.testTargets, ["UnitTests", "IntegrationTests", "UITests"])
    }
    
    func testYAMLParsingCorrectness_ParallelTesting() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      parallel_testing: true
      parallel_testing_workers: 8
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertEqual(spec.parallelTesting, true)
        XCTAssertEqual(spec.parallelTestingWorkers, 8)
    }
    
    func testYAMLParsingCorrectness_OptionalFieldsOmitted() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        XCTAssertNil(spec.buildConfiguration)
        XCTAssertNil(spec.signing)
        XCTAssertNil(spec.testTargets)
        XCTAssertNil(spec.archivePath)
        XCTAssertNil(spec.exportPath)
        XCTAssertNil(spec.exportMethod)
        XCTAssertNil(spec.exportOptionsPlist)
        XCTAssertNil(spec.buildOutputPath)
        XCTAssertNil(spec.parallelTesting)
        XCTAssertNil(spec.parallelTestingWorkers)
    }
}
