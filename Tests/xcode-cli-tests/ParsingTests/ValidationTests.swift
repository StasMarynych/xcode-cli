import Testing

@testable import xcode_cli

@Suite("Validation Rules Tests")
struct ValidationRulesTests {
    
    let validator = ConfigurationValidator()
    
    struct ProjectWorkspaceTestCase {
        let project: String?
        let workspace: String?
        let shouldPass: Bool
        let expectedError: ValidationError?
        let description: String
    }
    
    @Test(
        "Project/workspace mutual exclusivity and requirement",
        arguments: [
            ProjectWorkspaceTestCase(
                project: "MyApp.xcodeproj", workspace: "MyApp.xcworkspace", shouldPass: false,
                expectedError: .bothProjectAndWorkspaceSpecified, description: "both specified"),
            ProjectWorkspaceTestCase(
                project: "MyApp.xcodeproj", workspace: nil, shouldPass: true, expectedError: nil,
                description: "project only"),
            ProjectWorkspaceTestCase(
                project: nil, workspace: "MyApp.xcworkspace", shouldPass: true, expectedError: nil,
                description: "workspace only"),
            ProjectWorkspaceTestCase(
                project: nil, workspace: nil, shouldPass: false,
                expectedError: .missingProjectOrWorkspace, description: "neither specified"),
        ]
    )
    func projectWorkspaceMutualExclusivity(testCase: ProjectWorkspaceTestCase) throws {
        let spec = AppSpec(
            projectPath: testCase.project,
            workspacePath: testCase.workspace,
            scheme: "MyScheme"
        )
        
        if testCase.shouldPass {
            #expect(throws: Never.self) {
                try validator.validate(spec)
            }
        } else {
            #expect(throws: testCase.expectedError!) {
                try validator.validate(spec)
            }
        }
    }
    
    struct ProvisioningProfileTestCase {
        let uuid: String?
        let name: String?
        let path: String?
        let shouldPass: Bool
        let description: String
    }
    
    @Test(
        "Provisioning profile mutual exclusivity",
        arguments: [
            ProvisioningProfileTestCase(
                uuid: "test-uuid", name: "test-name", path: nil, shouldPass: false,
                description: "UUID and name"),
            ProvisioningProfileTestCase(
                uuid: "test-uuid", name: nil, path: "/path/to/profile", shouldPass: false,
                description: "UUID and path"),
            ProvisioningProfileTestCase(
                uuid: nil, name: "test-name", path: "/path/to/profile", shouldPass: false,
                description: "name and path"),
            ProvisioningProfileTestCase(
                uuid: "test-uuid", name: "test-name", path: "/path/to/profile", shouldPass: false,
                description: "all three"),
            ProvisioningProfileTestCase(
                uuid: "test-uuid", name: nil, path: nil, shouldPass: true, description: "UUID only"),
            ProvisioningProfileTestCase(
                uuid: nil, name: "test-name", path: nil, shouldPass: true, description: "name only"),
            ProvisioningProfileTestCase(
                uuid: nil, name: nil, path: "/path/to/profile", shouldPass: true, description: "path only"
            ),
            ProvisioningProfileTestCase(
                uuid: nil, name: nil, path: nil, shouldPass: true, description: "none specified"),
        ]
    )
    func provisioningProfileMutualExclusivity(testCase: ProvisioningProfileTestCase) throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(
                    uuid: testCase.uuid,
                    name: testCase.name,
                    path: testCase.path
                )
            )
        )
        
        if testCase.shouldPass {
            #expect(throws: Never.self) {
                try validator.validate(spec)
            }
        } else {
            #expect(throws: ValidationError.multipleProvisioningProfileFieldsSpecified) {
                try validator.validate(spec)
            }
        }
    }
    
    @Test(
        "Validation accepts valid export methods",
        arguments: [ExportMethod.appStore, .adHoc, .enterprise, .development]
    )
    func validationValidExportMethods(method: ExportMethod) throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            exportMethod: method
        )
        
        #expect(throws: Never.self) {
            try validator.validate(spec)
        }
    }
    
    @Test("Validation accepts no signing configuration")
    func validationNoSigningConfiguration() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: nil
        )
        
        #expect(throws: Never.self) {
            try validator.validate(spec)
        }
    }
    
    @Test("Validation accepts signing without provisioning profile")
    func validationSigningWithoutProvisioningProfile() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                style: .manual,
                identity: "Apple Distribution",
                teamID: "TEAM123"
            )
        )
        
        #expect(throws: Never.self) {
            try validator.validate(spec)
        }
    }
    
    @Test("Validation accepts complex valid spec")
    func validationComplexValidSpec() throws {
        let spec = AppSpec(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            signing: SigningConfiguration(
                style: .manual,
                identity: "Apple Distribution",
                teamID: "TEAM123",
                provisioningProfile: ProvisioningProfile(uuid: "test-uuid")
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
        
        #expect(throws: Never.self) {
            try validator.validate(spec)
        }
    }
}
