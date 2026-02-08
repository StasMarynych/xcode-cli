import Testing
import Yams

@testable import xcode_cli

@Suite("YAML Parser Tests")
struct YAMLParserTests {
    
    @Test("YAML round-trip preserves full spec")
    func yamlFullSpec() throws {
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
        
        #expect(originalSpec == parsedSpec, "Round-trip should preserve all fields")
    }
    
    @Test("YAML round-trip preserves minimal spec")
    func yamlMinimalSpec() throws {
        let originalSpec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme"
        )
        
        let encoder = YAMLEncoder()
        let yamlString = try encoder.encode(originalSpec)
        
        let decoder = YAMLDecoder()
        let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)
        
        #expect(originalSpec == parsedSpec, "Round-trip should preserve minimal spec")
    }
    
    @Test("YAML round-trip preserves workspace spec")
    func yamlWorkspaceSpec() throws {
        let originalSpec = AppSpec(
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme",
            buildConfiguration: "Debug"
        )
        
        let encoder = YAMLEncoder()
        let yamlString = try encoder.encode(originalSpec)
        
        let decoder = YAMLDecoder()
        let parsedSpec = try decoder.decode(AppSpec.self, from: yamlString)
        
        #expect(originalSpec == parsedSpec, "Round-trip should preserve workspace spec")
    }
}
