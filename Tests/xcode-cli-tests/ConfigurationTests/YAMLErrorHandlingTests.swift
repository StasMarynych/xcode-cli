import Foundation
import XCTest

@testable import xcode_cli

final class YAMLErrorHandlingTests: XCTestCase {
    
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
    
    func testFileNotFound() throws {
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.yaml")
        
        XCTAssertThrowsError(try parser.parse(fileURL: nonExistentURL)) { error in
            guard case YAMLParserError.fileNotFound(let url) = error else {
                XCTFail("Expected fileNotFound error, got \(error)")
                return
            }
            XCTAssertEqual(url, nonExistentURL)
        }
    }
    
    func testMalformedYAML_InvalidSyntax() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme
      invalid yaml syntax here [[[
      """
        
        let fileURL = tempDirectory.appendingPathComponent("malformed.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidYAML = error else {
                XCTFail("Expected invalidYAML error, got \(error)")
                return
            }
        }
    }
    
    func testMalformedYAML_InvalidIndentation() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
          signing:
      style: "manual"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("malformed.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidYAML = error else {
                XCTFail("Expected invalidYAML error, got \(error)")
                return
            }
        }
    }
    
    func testMissingRequiredField_Scheme() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      build_configuration: "Release"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("missing-scheme.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.missingRequiredField(let field) = error else {
                XCTFail("Expected missingRequiredField error, got \(error)")
                return
            }
            XCTAssertEqual(field, "scheme")
        }
    }
    
    func testInvalidFieldType_SchemeNotString() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: 12345
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let spec = try parser.parse(fileURL: fileURL)
        XCTAssertEqual(spec.scheme, "12345")
    }
    
    func testInvalidFieldType_ParallelTestingNotBoolean() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      parallel_testing: "yes"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidFieldType(let field, let expected) = error else {
                XCTFail("Expected invalidFieldType error, got \(error)")
                return
            }
            XCTAssertEqual(field, "parallel_testing")
            XCTAssertTrue(expected.contains("Bool"))
        }
    }
    
    func testInvalidFieldType_ParallelTestingWorkersNotInteger() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      parallel_testing_workers: "four"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidFieldType(let field, let expected) = error else {
                XCTFail("Expected invalidFieldType error, got \(error)")
                return
            }
            XCTAssertEqual(field, "parallel_testing_workers")
            XCTAssertTrue(expected.contains("Int"))
        }
    }
    
    func testInvalidFieldType_TestTargetsNotArray() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      test_targets: "UnitTests"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidFieldType = error else {
                XCTFail("Expected invalidFieldType error, got \(error)")
                return
            }
        }
    }
    
    func testInvalidFieldType_SigningNotObject() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing: "manual"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-type.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidFieldType = error else {
                XCTFail("Expected invalidFieldType error, got \(error)")
                return
            }
        }
    }
    
    func testInvalidEnumValue_ExportMethod() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      export_method: "invalid-method"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-enum.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidYAML = error else {
                XCTFail("Expected invalidYAML error for invalid enum, got \(error)")
                return
            }
        }
    }
    
    func testInvalidEnumValue_CodeSignStyle() throws {
        let yamlContent = """
      project_path: "Test.xcodeproj"
      scheme: "TestScheme"
      signing:
          style: "invalid-style"
      """
        
        let fileURL = tempDirectory.appendingPathComponent("invalid-enum.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidYAML = error else {
                XCTFail("Expected invalidYAML error for invalid enum, got \(error)")
                return
            }
        }
    }
    
    func testEmptyYAMLFile() throws {
        let yamlContent = ""
        
        let fileURL = tempDirectory.appendingPathComponent("empty.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidFieldType = error else {
                XCTFail("Expected invalidFieldType error, got \(error)")
                return
            }
        }
    }
    
    func testYAMLWithOnlyComments() throws {
        let yamlContent = """
      # This is a comment
      # Another comment
      """
        
        let fileURL = tempDirectory.appendingPathComponent("comments-only.yaml")
        try yamlContent.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try parser.parse(fileURL: fileURL)) { error in
            guard case YAMLParserError.invalidFieldType = error else {
                XCTFail("Expected invalidFieldType error, got \(error)")
                return
            }
        }
    }
    
    func testNestedFieldError_ProvisioningProfileUUID() throws {
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
        XCTAssertEqual(spec.signing?.provisioningProfile?.uuid, "12345")
    }
    
    func testSerializationError_ValidSpec() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme"
        )
        
        let yamlString = try parser.serialize(spec)
        
        XCTAssertTrue(yamlString.contains("project_path"))
        XCTAssertTrue(yamlString.contains("scheme"))
        XCTAssertTrue(yamlString.contains("Test.xcodeproj"))
        XCTAssertTrue(yamlString.contains("TestScheme"))
    }
}
