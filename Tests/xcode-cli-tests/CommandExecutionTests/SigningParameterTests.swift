import Testing

@testable import xcode_cli

@Suite("Signing Parameter Inclusion Tests")
struct SigningParameterTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Signing identity is included when specified")
    func testSigningIdentityIncluded() {
        let signing = SigningConfiguration(
            identity: "Apple Distribution: My Company (TEAM123)"
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_IDENTITY=Apple Distribution: My Company (TEAM123)"))
    }
    
    @Test("Team ID is included when specified")
    func testTeamIDIncluded() {
        let signing = SigningConfiguration(
            teamID: "TEAM123456"
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("DEVELOPMENT_TEAM=TEAM123456"))
    }
    
    @Test("Code sign style is included when specified")
    func testCodeSignStyleIncluded() {
        let signing = SigningConfiguration(
            style: .manual
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
    }
    
    @Test("Provisioning profile UUID is included when specified")
    func testProvisioningProfileUUIDIncluded() {
        let provisioningProfile = ProvisioningProfile(
            uuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        )
        let signing = SigningConfiguration(
            provisioningProfile: provisioningProfile
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("PROVISIONING_PROFILE=a1b2c3d4-e5f6-7890-abcd-ef1234567890"))
        #expect(!arguments.contains(where: { $0.contains("PROVISIONING_PROFILE_SPECIFIER") }))
    }
    
    @Test("Provisioning profile name is included when specified")
    func testProvisioningProfileNameIncluded() {
        let provisioningProfile = ProvisioningProfile(
            name: "MyApp Distribution Profile"
        )
        let signing = SigningConfiguration(
            provisioningProfile: provisioningProfile
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("PROVISIONING_PROFILE_SPECIFIER=MyApp Distribution Profile"))
        #expect(!arguments.contains(where: { $0.hasPrefix("PROVISIONING_PROFILE=") }))
    }
    
    @Test("Provisioning profile path is included when specified")
    func testProvisioningProfilePathIncluded() {
        let provisioningProfile = ProvisioningProfile(
            path: "/path/to/profile.mobileprovision"
        )
        let signing = SigningConfiguration(
            provisioningProfile: provisioningProfile
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("PROVISIONING_PROFILE=/path/to/profile.mobileprovision"))
        #expect(!arguments.contains(where: { $0.contains("PROVISIONING_PROFILE_SPECIFIER") }))
    }
    
    @Test("All signing parameters are included when specified")
    func testAllSigningParametersIncluded() {
        let provisioningProfile = ProvisioningProfile(
            uuid: "test-uuid-1234"
        )
        let signing = SigningConfiguration(
            style: .manual,
            identity: "Apple Distribution: Test Company",
            teamID: "TESTTEAM",
            provisioningProfile: provisioningProfile
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
        #expect(arguments.contains("CODE_SIGN_IDENTITY=Apple Distribution: Test Company"))
        #expect(arguments.contains("DEVELOPMENT_TEAM=TESTTEAM"))
        #expect(arguments.contains("PROVISIONING_PROFILE=test-uuid-1234"))
    }
    
    @Test("No signing parameters when signing is nil")
    func testNoSigningParametersWhenNil() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: nil
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(!arguments.contains(where: { $0.contains("CODE_SIGN_STYLE") }))
        #expect(!arguments.contains(where: { $0.contains("CODE_SIGN_IDENTITY") }))
        #expect(!arguments.contains(where: { $0.contains("DEVELOPMENT_TEAM") }))
        #expect(!arguments.contains(where: { $0.contains("PROVISIONING_PROFILE") }))
    }
    
    @Test("Automatic code sign style is included correctly")
    func testAutomaticCodeSignStyle() {
        let signing = SigningConfiguration(
            style: .automatic
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=automatic"))
    }
    
    @Test("Manual code sign style is included correctly")
    func testManualCodeSignStyle() {
        let signing = SigningConfiguration(
            style: .manual
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
    }
    
    @Test("Partial signing configuration is handled correctly")
    func testPartialSigningConfiguration() {
        let signing = SigningConfiguration(
            identity: "Apple Distribution",
            teamID: "TEAM123"
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: signing
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_IDENTITY=Apple Distribution"))
        #expect(arguments.contains("DEVELOPMENT_TEAM=TEAM123"))
        #expect(!arguments.contains(where: { $0.contains("CODE_SIGN_STYLE") }))
        #expect(!arguments.contains(where: { $0.contains("PROVISIONING_PROFILE") }))
    }
}
