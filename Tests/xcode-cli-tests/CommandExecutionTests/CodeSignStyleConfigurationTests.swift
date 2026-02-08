import Testing

@testable import xcode_cli

@Suite("Code Sign Style Configuration Tests")
struct CodeSignStyleConfigurationTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Build arguments include CODE_SIGN_STYLE=manual when style is manual")
    func testManualCodeSignStyle() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: SigningConfiguration(style: .manual)
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
    }
    
    @Test("Build arguments include CODE_SIGN_STYLE=automatic when style is automatic")
    func testAutomaticCodeSignStyle() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: SigningConfiguration(style: .automatic)
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=automatic"))
    }
    
    @Test("Build arguments exclude CODE_SIGN_STYLE when style is nil")
    func testCodeSignStyleExcludedWhenNil() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: SigningConfiguration(style: nil)
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        let hasCodeSignStyle = arguments.contains { $0.hasPrefix("CODE_SIGN_STYLE=") }
        #expect(!hasCodeSignStyle)
    }
    
    @Test("Build arguments exclude CODE_SIGN_STYLE when signing is nil")
    func testCodeSignStyleExcludedWhenSigningNil() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: nil
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        let hasCodeSignStyle = arguments.contains { $0.hasPrefix("CODE_SIGN_STYLE=") }
        #expect(!hasCodeSignStyle)
    }
    
    @Test("Test arguments include CODE_SIGN_STYLE when specified")
    func testCodeSignStyleInTestCommand() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: SigningConfiguration(style: .manual)
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
    }
    
    @Test("Archive arguments include CODE_SIGN_STYLE when specified")
    func testCodeSignStyleInArchiveCommand() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            signing: SigningConfiguration(style: .automatic),
            archivePath: "/output/MyApp.xcarchive"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=automatic"))
    }
    
    @Test("Code sign style appears after action in arguments")
    func testCodeSignStylePosition() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: SigningConfiguration(style: .manual)
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        if let codeSignStyleIndex = arguments.firstIndex(of: "CODE_SIGN_STYLE=manual"),
           let buildIndex = arguments.firstIndex(of: "build")
        {
            #expect(codeSignStyleIndex > buildIndex)
        }
    }
    
    @Test("Code sign style works with other signing parameters")
    func testCodeSignStyleWithOtherSigningParams() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            signing: SigningConfiguration(
                style: .manual,
                identity: "Apple Distribution",
                teamID: "TEAM123",
                provisioningProfile: ProvisioningProfile(uuid: "test-uuid")
            )
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
        #expect(arguments.contains("CODE_SIGN_IDENTITY=Apple Distribution"))
        #expect(arguments.contains("DEVELOPMENT_TEAM=TEAM123"))
        #expect(arguments.contains("PROVISIONING_PROFILE=test-uuid"))
    }
}
