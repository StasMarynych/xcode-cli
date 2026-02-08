import XCTest
import Yams

@testable import xcode_cli

final class YAMLParserTests: XCTestCase {

  func testYAMLRoundTripPreservation_FullSpec() throws {
    let originalSpec = AppSpec(
      projectPath: "MyApp.xcodeproj",
      workspacePath: nil,
      scheme: "MyScheme",
      buildConfiguration: "Release",
      signing: SigningConfiguration(
        style: .manual,
        identity: "Apple Distribution",
        teamID: "TEAM123",
        provisioningProfile: ProvisioningProfile(uuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
      ),
      testTargets: ["UnitTests", "UITests"],
      archivePath: "./build/archive.xcarchive",
      exportPath: "./build",
      exportMethod: .appStore,
      exportOptionsPlist: "./ExportOptions.plist",
      buildOutputPath: "./DerivedData",
      parallelTesting: true,
      parallelTestingWorkers: 4
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should preserve all fields")
  }

  func testYAMLRoundTripPreservation_MinimalSpec() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme"
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should preserve minimal spec")
  }

  func testYAMLRoundTripPreservation_WorkspaceSpec() throws {
    let originalSpec = AppSpec(
      workspacePath: "MyApp.xcworkspace",
      scheme: "MyScheme",
      buildConfiguration: "Debug"
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should preserve workspace spec")
  }

  func testYAMLRoundTripPreservation_VariousExportMethods() throws {
    let exportMethods: [ExportMethod] = [.appStore, .adHoc, .enterprise, .development]

    for method in exportMethods {
      let originalSpec = AppSpec(
        projectPath: "Test.xcodeproj",
        scheme: "TestScheme",
        exportMethod: method
      )

      let encoder = YAMLEncoder()
      let yamlString = try encoder.encode(originalSpec)

      let decoder = YAMLDecoder()
      let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

      XCTAssertEqual(
        originalSpec, parsedSpec, "Round-trip should preserve export method: \(method)")
    }
  }

  func testYAMLRoundTripPreservation_VariousCodeSignStyles() throws {
    let styles: [CodeSignStyle] = [.automatic, .manual]

    for style in styles {
      let originalSpec = AppSpec(
        projectPath: "Test.xcodeproj",
        scheme: "TestScheme",
        signing: SigningConfiguration(style: style)
      )

      let encoder = YAMLEncoder()
      let yamlString = try encoder.encode(originalSpec)

      let decoder = YAMLDecoder()
      let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

      XCTAssertEqual(
        originalSpec, parsedSpec, "Round-trip should preserve code sign style: \(style)")
    }
  }

  func testYAMLRoundTripPreservation_ProvisioningProfileByUUID() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme",
      signing: SigningConfiguration(
        provisioningProfile: ProvisioningProfile(uuid: "test-uuid-1234")
      )
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should preserve provisioning profile UUID")
  }

  func testYAMLRoundTripPreservation_ProvisioningProfileByName() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme",
      signing: SigningConfiguration(
        provisioningProfile: ProvisioningProfile(name: "MyApp Distribution Profile")
      )
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should preserve provisioning profile name")
  }

  func testYAMLRoundTripPreservation_ProvisioningProfileByPath() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme",
      signing: SigningConfiguration(
        provisioningProfile: ProvisioningProfile(path: "/path/to/profile.mobileprovision")
      )
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should preserve provisioning profile path")
  }

  func testYAMLRoundTripPreservation_EmptyTestTargets() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme",
      testTargets: []
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should preserve empty test targets array")
  }

  func testYAMLRoundTripPreservation_ParallelTestingDisabled() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme",
      parallelTesting: false
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should preserve parallel testing disabled")
  }

  func testYAMLRoundTripPreservation_ParallelTestingEnabled() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme",
      parallelTesting: true,
      parallelTestingWorkers: 8
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(
      originalSpec, parsedSpec, "Round-trip should preserve parallel testing configuration")
  }

  func testSigningConfigurationRoundTrip_Full() throws {
    let originalConfig = SigningConfiguration(
      style: .manual,
      identity: "Apple Distribution: My Company",
      teamID: "ABC123XYZ",
      provisioningProfile: ProvisioningProfile(uuid: "profile-uuid")
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalConfig)

    let decoder = YAMLDecoder()
    let parsedConfig = try decoder.decode(SigningConfiguration.self, from: yamlString)

    XCTAssertEqual(
      originalConfig, parsedConfig, "SigningConfiguration round-trip should preserve all fields")
  }

  func testSigningConfigurationRoundTrip_Minimal() throws {
    let originalConfig = SigningConfiguration()

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalConfig)

    let decoder = YAMLDecoder()
    let parsedConfig = try decoder.decode(SigningConfiguration.self, from: yamlString)

    XCTAssertEqual(
      originalConfig, parsedConfig, "SigningConfiguration round-trip should preserve minimal config"
    )
  }

  func testProvisioningProfileRoundTrip_UUID() throws {
    let originalProfile = ProvisioningProfile(uuid: "test-uuid-12345")

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalProfile)

    let decoder = YAMLDecoder()
    let parsedProfile = try decoder.decode(ProvisioningProfile.self, from: yamlString)

    XCTAssertEqual(
      originalProfile, parsedProfile, "ProvisioningProfile round-trip should preserve UUID")
  }

  func testProvisioningProfileRoundTrip_Name() throws {
    let originalProfile = ProvisioningProfile(name: "Distribution Profile")

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalProfile)

    let decoder = YAMLDecoder()
    let parsedProfile = try decoder.decode(ProvisioningProfile.self, from: yamlString)

    XCTAssertEqual(
      originalProfile, parsedProfile, "ProvisioningProfile round-trip should preserve name")
  }

  func testProvisioningProfileRoundTrip_Path() throws {
    let originalProfile = ProvisioningProfile(path: "/custom/path/profile.mobileprovision")

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalProfile)

    let decoder = YAMLDecoder()
    let parsedProfile = try decoder.decode(ProvisioningProfile.self, from: yamlString)

    XCTAssertEqual(
      originalProfile, parsedProfile, "ProvisioningProfile round-trip should preserve path")
  }

  func testProvisioningProfileRoundTrip_Empty() throws {
    let originalProfile = ProvisioningProfile()

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalProfile)

    let decoder = YAMLDecoder()
    let parsedProfile = try decoder.decode(ProvisioningProfile.self, from: yamlString)

    XCTAssertEqual(
      originalProfile, parsedProfile, "ProvisioningProfile round-trip should preserve empty profile"
    )
  }

  func testCodeSignStyleRoundTrip() throws {
    for style in [CodeSignStyle.automatic, CodeSignStyle.manual] {
      let encoder = YAMLEncoder()
      let yamlString = try encoder.encode(style)

      let decoder = YAMLDecoder()
      let parsedStyle = try decoder.decode(CodeSignStyle.self, from: yamlString)

      XCTAssertEqual(style, parsedStyle, "CodeSignStyle round-trip should preserve \(style)")
    }
  }

  func testExportMethodRoundTrip() throws {
    for method in [
      ExportMethod.appStore, ExportMethod.adHoc, ExportMethod.enterprise, ExportMethod.development,
    ] {
      let encoder = YAMLEncoder()
      let yamlString = try encoder.encode(method)

      let decoder = YAMLDecoder()
      let parsedMethod = try decoder.decode(ExportMethod.self, from: yamlString)

      XCTAssertEqual(method, parsedMethod, "ExportMethod round-trip should preserve \(method)")
    }
  }

  func testOptionalFieldHandling_AllNil() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme",
      buildConfiguration: nil,
      signing: nil,
      testTargets: nil,
      archivePath: nil,
      exportPath: nil,
      exportMethod: nil,
      exportOptionsPlist: nil,
      buildOutputPath: nil,
      parallelTesting: nil,
      parallelTestingWorkers: nil
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(originalSpec, parsedSpec, "Round-trip should handle all optional fields as nil")
  }

  func testOptionalFieldHandling_MixedNilAndValues() throws {
    let originalSpec = AppSpec(
      projectPath: "Test.xcodeproj",
      scheme: "TestScheme",
      buildConfiguration: "Debug",
      signing: nil,
      testTargets: ["Tests"],
      archivePath: nil,
      exportPath: "./build",
      exportMethod: nil,
      exportOptionsPlist: nil,
      buildOutputPath: "./DerivedData",
      parallelTesting: true,
      parallelTestingWorkers: nil
    )

    let encoder = YAMLEncoder()
    let yamlString = try encoder.encode(originalSpec)

    let decoder = YAMLDecoder()
    let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)

    XCTAssertEqual(
      originalSpec, parsedSpec, "Round-trip should handle mixed nil and non-nil optional fields")
  }
}
