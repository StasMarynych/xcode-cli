import Testing

@testable import xcode_cli

@Suite("Build Command Argument Construction Tests")
struct BuildCommandArgumentTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Build arguments include project path when specified")
    func testBuildArgumentsWithProject() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-project"))
        #expect(arguments.contains("MyApp.xcodeproj"))
        #expect(!arguments.contains("-workspace"))
    }
    
    @Test("Build arguments include workspace path when specified")
    func testBuildArgumentsWithWorkspace() {
        let config = Configuration(
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-workspace"))
        #expect(arguments.contains("MyApp.xcworkspace"))
        #expect(!arguments.contains("-project"))
    }
    
    @Test("Build arguments include scheme")
    func testBuildArgumentsIncludeScheme() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-scheme"))
        #expect(arguments.contains("TestScheme"))
    }
    
    @Test("Build arguments include configuration")
    func testBuildArgumentsIncludeConfiguration() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-configuration"))
        #expect(arguments.contains("Debug"))
    }
    
    @Test("Build arguments include destination")
    func testBuildArgumentsIncludeDestination() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15 Pro", os: "17.2")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-destination"))
        let destinationIndex = arguments.firstIndex(of: "-destination")!
        let destinationValue = arguments[destinationIndex + 1]
        #expect(destinationValue.contains("iPhone 15 Pro"))
        #expect(destinationValue.contains("17.2"))
    }
    
    @Test("Build arguments include build action")
    func testBuildArgumentsIncludeBuildAction() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("build"))
    }
    
    @Test("Build arguments with all required parameters")
    func testBuildArgumentsComplete() {
        let config = Configuration(
            projectPath: "CompleteApp.xcodeproj",
            scheme: "CompleteScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        // Verify all required parameters are present
        #expect(arguments.contains("-project"))
        #expect(arguments.contains("CompleteApp.xcodeproj"))
        #expect(arguments.contains("-scheme"))
        #expect(arguments.contains("CompleteScheme"))
        #expect(arguments.contains("-configuration"))
        #expect(arguments.contains("Release"))
        #expect(arguments.contains("-destination"))
        #expect(arguments.contains("build"))
    }
    
    @Test("Build arguments order is correct")
    func testBuildArgumentsOrder() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        // Verify that flags come before their values
        if let projectIndex = arguments.firstIndex(of: "-project") {
            #expect(projectIndex + 1 < arguments.count)
            #expect(arguments[projectIndex + 1] == "Test.xcodeproj")
        }
        
        if let schemeIndex = arguments.firstIndex(of: "-scheme") {
            #expect(schemeIndex + 1 < arguments.count)
            #expect(arguments[schemeIndex + 1] == "TestScheme")
        }
    }
}

// Mock ProcessRunner for testing
struct MockProcessRunner: ProcessRunnerProtocol {
    func run(
        executable: String,
        arguments: [String],
        streamOutput: Bool
    ) async throws -> ExecutionResult {
        ExecutionResult(exitCode: 0, stdout: "", stderr: "")
    }
}
