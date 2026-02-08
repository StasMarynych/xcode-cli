import XCTest

@testable import xcode_cli

final class ValidationRulesTests: XCTestCase {
    
    var validator: ConfigurationValidator!
    
    override func setUp() {
        super.setUp()
        validator = ConfigurationValidator()
    }
    
    func testMutualExclusivityValidation_BothProjectAndWorkspace() throws {
        let spec = AppSpec(
            projectPath: "MyApp.xcodeproj",
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme"
        )
        
        XCTAssertThrowsError(try validator.validate(spec)) { error in
            XCTAssertEqual(error as? ValidationError, .bothProjectAndWorkspaceSpecified)
        }
    }
    
    func testMutualExclusivityValidation_ProjectOnly() throws {
        let spec = AppSpec(
            projectPath: "MyApp.xcodeproj",
            workspacePath: nil,
            scheme: "MyScheme"
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testMutualExclusivityValidation_WorkspaceOnly() throws {
        let spec = AppSpec(
            projectPath: nil,
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme"
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testRequiredProjectSourceValidation_NeitherProjectNorWorkspace() throws {
        let spec = AppSpec(
            projectPath: nil,
            workspacePath: nil,
            scheme: "MyScheme"
        )
        
        XCTAssertThrowsError(try validator.validate(spec)) { error in
            XCTAssertEqual(error as? ValidationError, .missingProjectOrWorkspace)
        }
    }
    
    func testRequiredProjectSourceValidation_ProjectProvided() throws {
        let spec = AppSpec(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme"
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testRequiredProjectSourceValidation_WorkspaceProvided() throws {
        let spec = AppSpec(
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme"
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testProvisioningProfileMutualExclusivity_UUIDAndName() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(
                    uuid: "test-uuid",
                    name: "test-name"
                )
            )
        )
        
        XCTAssertThrowsError(try validator.validate(spec)) { error in
            XCTAssertEqual(error as? ValidationError, .multipleProvisioningProfileFieldsSpecified)
        }
    }
    
    func testProvisioningProfileMutualExclusivity_UUIDAndPath() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(
                    uuid: "test-uuid",
                    path: "/path/to/profile"
                )
            )
        )
        
        XCTAssertThrowsError(try validator.validate(spec)) { error in
            XCTAssertEqual(error as? ValidationError, .multipleProvisioningProfileFieldsSpecified)
        }
    }
    
    func testProvisioningProfileMutualExclusivity_NameAndPath() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(
                    name: "test-name",
                    path: "/path/to/profile"
                )
            )
        )
        
        XCTAssertThrowsError(try validator.validate(spec)) { error in
            XCTAssertEqual(error as? ValidationError, .multipleProvisioningProfileFieldsSpecified)
        }
    }
    
    func testProvisioningProfileMutualExclusivity_AllThree() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(
                    uuid: "test-uuid",
                    name: "test-name",
                    path: "/path/to/profile"
                )
            )
        )
        
        XCTAssertThrowsError(try validator.validate(spec)) { error in
            XCTAssertEqual(error as? ValidationError, .multipleProvisioningProfileFieldsSpecified)
        }
    }
    
    func testProvisioningProfileMutualExclusivity_UUIDOnly() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(uuid: "test-uuid")
            )
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testProvisioningProfileMutualExclusivity_NameOnly() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(name: "test-name")
            )
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testProvisioningProfileMutualExclusivity_PathOnly() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile(path: "/path/to/profile")
            )
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testProvisioningProfileMutualExclusivity_NoneSpecified() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                provisioningProfile: ProvisioningProfile()
            )
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testValidation_ValidExportMethods() throws {
        let exportMethods: [ExportMethod] = [.appStore, .adHoc, .enterprise, .development]
        
        for method in exportMethods {
            let spec = AppSpec(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                exportMethod: method
            )
            
            XCTAssertNoThrow(
                try validator.validate(spec), "Validation should pass for export method: \(method)")
        }
    }
    
    func testValidation_NoSigningConfiguration() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: nil
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testValidation_SigningWithoutProvisioningProfile() throws {
        let spec = AppSpec(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            signing: SigningConfiguration(
                style: .manual,
                identity: "Apple Distribution",
                teamID: "TEAM123"
            )
        )
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
    
    func testValidation_ComplexValidSpec() throws {
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
        
        XCTAssertNoThrow(try validator.validate(spec))
    }
}
