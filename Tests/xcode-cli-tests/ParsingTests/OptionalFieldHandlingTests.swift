import Foundation
import Testing

@testable import xcode_cli

@Suite("Optional Field Handling Tests")
struct OptionalFieldHandlingTests {
    
    func createTempDirectory() -> URL {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }
    
    @Test("Optional field handling minimal spec")
    func optionalFieldHandlingMinimalSpec() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "MyApp.xcodeproj"
      scheme: "MyScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        #expect(spec.buildConfiguration == nil)
        #expect(spec.signing == nil)
        #expect(spec.testTargets == nil)
        #expect(spec.archivePath == nil)
        #expect(spec.exportPath == nil)
        #expect(spec.exportMethod == nil)
        #expect(spec.exportOptionsPlist == nil)
        #expect(spec.buildOutputPath == nil)
        #expect(spec.parallelTesting == nil)
        #expect(spec.parallelTestingWorkers == nil)
    }
    
    @Test("Optional field handling build configuration omitted")
    func optionalFieldHandlingBuildConfigurationOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.buildConfiguration == "Release")
    }
    
    @Test("Optional field handling signing omitted")
    func optionalFieldHandlingSigningOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.signing == nil)
    }
    
    @Test("Optional field handling test targets omitted")
    func optionalFieldHandlingTestTargetsOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.testTargets == [])
    }
    
    @Test("Optional field handling archive path omitted")
    func optionalFieldHandlingArchivePathOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.archivePath == nil)
    }
    
    @Test("Optional field handling export path omitted")
    func optionalFieldHandlingExportPathOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.exportPath == nil)
    }
    
    @Test("Optional field handling export method omitted")
    func optionalFieldHandlingExportMethodOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.exportMethod == nil)
    }
    
    @Test("Optional field handling build output path omitted")
    func optionalFieldHandlingBuildOutputPathOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.buildOutputPath == nil)
    }
    
    @Test("Optional field handling parallel testing omitted")
    func optionalFieldHandlingParallelTestingOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.parallelTesting == false)
    }
    
    @Test("Optional field handling parallel testing workers omitted")
    func optionalFieldHandlingParallelTestingWorkersOmitted() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        let merger = ConfigurationMerger()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        let flags = CommandFlags(destination: "platform=iOS Simulator")
        let config = try merger.merge(spec: spec, flags: flags)
        
        #expect(config.parallelTestingWorkers == nil)
    }
    
    @Test("Optional field handling partial signing configuration")
    func optionalFieldHandlingPartialSigningConfiguration() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing:
          identity: "Apple Distribution"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        #expect(spec.signing != nil)
        #expect(spec.signing?.identity == "Apple Distribution")
        #expect(spec.signing?.style == nil)
        #expect(spec.signing?.teamID == nil)
        #expect(spec.signing?.provisioningProfile == nil)
    }
    
    @Test("Optional field handling empty test targets array")
    func optionalFieldHandlingEmptyTestTargetsArray() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      test_targets: []
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        #expect(spec.testTargets != nil)
        #expect(spec.testTargets == [])
    }
    
    @Test("Optional field handling mixed optional fields")
    func optionalFieldHandlingMixedOptionalFields() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      build_configuration: "Debug"
      archive_path: "./build/archive.xcarchive"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("test.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        
        #expect(spec.buildConfiguration == "Debug")
        #expect(spec.archivePath == "./build/archive.xcarchive")
        #expect(spec.signing == nil)
        #expect(spec.testTargets == nil)
        #expect(spec.exportPath == nil)
        #expect(spec.exportMethod == nil)
        #expect(spec.buildOutputPath == nil)
        #expect(spec.parallelTesting == nil)
    }
}
