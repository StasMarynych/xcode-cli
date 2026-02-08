import Foundation
import Testing

@testable import xcode_cli

@Suite("YAML Error Handling Tests")
struct YAMLErrorHandlingTests {
    
    func createTempDirectory() -> URL {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }
    
    @Test("File not found error")
    func fileNotFound() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.yaml")
        
        #expect(throws: YAMLParserError.fileNotFound(nonExistentURL)) {
            try parser.parse(fileURL: nonExistentURL)
        }
    }
    
    @Test("Malformed YAML with invalid syntax")
    func malformedYAMLInvalidSyntax() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme
      invalid yaml syntax here [[[
      """
        
        let fileURL = tempDirectory.appendingPathComponent("malformed.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Malformed YAML with invalid indentation")
    func malformedYAMLInvalidIndentation() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
          signing:
      style: "manual"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("malformed.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Missing required field scheme")
    func missingRequiredFieldScheme() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      build_configuration: "Release"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("missing-scheme.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.missingRequiredField("scheme")) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Invalid field type scheme not string")
    func invalidFieldTypeSchemeNotString() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: 12345
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        #expect(spec.scheme == "12345")
    }
    
    @Test("Invalid field type parallel testing not boolean")
    func invalidFieldTypeParallelTestingNotBoolean() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      parallel_testing: "yes"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Invalid field type parallel testing workers not integer")
    func invalidFieldTypeParallelTestingWorkersNotInteger() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      parallel_testing_workers: "four"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Invalid field type test targets not array")
    func invalidFieldTypeTestTargetsNotArray() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      test_targets: "UnitTests"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Invalid field type signing not object")
    func invalidFieldTypeSigningNotObject() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing: "manual"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Invalid enum value export method")
    func invalidEnumValueExportMethod() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      export_method: "invalid-method"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-enum.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Invalid enum value code sign style")
    func invalidEnumValueCodeSignStyle() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing:
          style: "invalid-style"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-enum.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Empty YAML file")
    func emptyYAMLFile() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = ""
        
        let fileURL = tempDirectory.appendingPathComponent("empty.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("YAML with only comments")
    func yamlWithOnlyComments() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      # This is a comment
      # Another comment
      """
        
        let fileURL = tempDirectory.appendingPathComponent("comments-only.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(throws: YAMLParserError.self) {
            try parser.parse(fileURL: fileURL)
        }
    }
    
    @Test("Nested field error provisioning profile UUID")
    func nestedFieldErrorProvisioningProfileUUID() throws {
        let tempDirectory = createTempDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }
        let parser = YAMLParser()
        
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing:
          provisioning_profile:
              uuid: 12345
      """
        
        let fileURL = tempDirectory.appendingPathComponent("nested-error.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        #expect(spec.signing?.provisioningProfile?.uuid == "12345")
    }
    
    @Test("Serialization error valid spec")
    func serializationErrorValidSpec() throws {
        let parser = YAMLParser()
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme"
        )
        
        let yamlString = try parser.serialize(spec)
        
        #expect(yamlString.contains("project_path"))
        #expect(yamlString.contains("scheme"))
        #expect(yamlString.contains("Test.xcodeproj"))
        #expect(yamlString.contains("TestScheme"))
    }
}
