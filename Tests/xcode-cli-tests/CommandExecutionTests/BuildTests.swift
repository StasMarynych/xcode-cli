import Testing

@testable import xcode_cli

@Suite("Build Command Tests")
struct BuildTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test(
        "Build arguments construction with various configurations",
        arguments: [
            (
                projectPath: "MyApp.xcodeproj" as String?, workspacePath: nil as String?,
                scheme: "MyScheme", config: "Release", deviceName: "iPhone 15", os: "17.0"
            ),
            (
                projectPath: "TestApp.xcodeproj" as String?, workspacePath: nil as String?,
                scheme: "TestScheme", config: "Debug", deviceName: "iPhone 15 Pro", os: "17.2"
            ),
            (
                projectPath: nil as String?, workspacePath: "MyApp.xcworkspace" as String?,
                scheme: "WorkspaceScheme", config: "Release", deviceName: "iPhone 15", os: "17.0"
            ),
            (
                projectPath: nil as String?, workspacePath: "TestApp.xcworkspace" as String?,
                scheme: "AnotherScheme", config: "Debug", deviceName: "iPhone 14", os: "16.0"
            ),
        ]
    )
    func testBuildArgumentsConstruction(
        projectPath: String?, workspacePath: String?, scheme: String, config: String,
        deviceName: String, os: String
    ) {
        let configuration = Configuration(
            projectPath: projectPath,
            workspacePath: workspacePath,
            scheme: scheme,
            buildConfiguration: config,
            destination: .simulator(name: deviceName, os: os)
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: configuration)
        
        if let project = projectPath {
            #expect(arguments.contains("-project"))
            #expect(arguments.contains(project))
            #expect(!arguments.contains("-workspace"))
        } else if let workspace = workspacePath {
            #expect(arguments.contains("-workspace"))
            #expect(arguments.contains(workspace))
            #expect(!arguments.contains("-project"))
        }
        
        #expect(arguments.contains("-scheme"))
        #expect(arguments.contains(scheme))
        #expect(arguments.contains("-configuration"))
        #expect(arguments.contains(config))
        #expect(arguments.contains("-destination"))
        #expect(arguments.contains("build"))
        
        let destinationIndex = arguments.firstIndex(of: "-destination")!
        let destinationValue = arguments[destinationIndex + 1]
        #expect(destinationValue.contains(deviceName))
        #expect(destinationValue.contains(os))
    }
    
    @Test("Build arguments handle project vs workspace correctly")
    func testProjectWorkspaceSelection() {
        let projectConfig = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let workspaceConfig = Configuration(
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let projectArgs = executor.buildXcodeBuildArguments(action: .build, config: projectConfig)
        #expect(projectArgs.contains("-project"))
        #expect(projectArgs.contains("MyApp.xcodeproj"))
        #expect(!projectArgs.contains("-workspace"))
        
        let workspaceArgs = executor.buildXcodeBuildArguments(
            action: .build, config: workspaceConfig)
        #expect(workspaceArgs.contains("-workspace"))
        #expect(workspaceArgs.contains("MyApp.xcworkspace"))
        #expect(!workspaceArgs.contains("-project"))
    }
    
    @Test("Successful build returns exit code 0")
    func testSuccessfulBuildReturnsZero() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 0,
            stdout: "Build succeeded",
            stderr: ""
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeBuild(config: config)
        
        #expect(result.exitCode == 0)
        #expect(result.isSuccess == true)
    }
    
    @Test("Failed build returns non-zero exit code")
    func testFailedBuildReturnsNonZero() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 65,
            stdout: "",
            stderr: "Build failed"
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeBuild(config: config)
        
        #expect(result.exitCode != 0)
        #expect(result.isSuccess == false)
    }
    
    @Test("Build execution calls xcodebuild with correct executable")
    func testBuildCallsXcodebuild() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        _ = try await executor.executeBuild(config: config)
        
        #expect(mockRunner.lastExecutable == "xcodebuild")
    }
    
    @Test("Build execution streams output")
    func testBuildStreamsOutput() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        _ = try await executor.executeBuild(config: config)
        
        #expect(mockRunner.lastStreamOutput == true)
    }
    
    @Test("Build execution passes correct arguments")
    func testBuildPassesCorrectArguments() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15 Pro", os: "17.2")
        )
        
        _ = try await executor.executeBuild(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-project"))
        #expect(arguments.contains("MyApp.xcodeproj"))
        #expect(arguments.contains("-scheme"))
        #expect(arguments.contains("MyScheme"))
        #expect(arguments.contains("-configuration"))
        #expect(arguments.contains("Debug"))
        #expect(arguments.contains("build"))
    }
    
    @Test("Build with workspace uses workspace argument")
    func testBuildWithWorkspace() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        _ = try await executor.executeBuild(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-workspace"))
        #expect(arguments.contains("MyApp.xcworkspace"))
        #expect(!arguments.contains("-project"))
    }
    
    @Test("Build with signing parameters includes them in arguments")
    func testBuildWithSigningParameters() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let signing = SigningConfiguration(
            style: .manual,
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
        
        _ = try await executor.executeBuild(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
        #expect(arguments.contains("CODE_SIGN_IDENTITY=Apple Distribution"))
        #expect(arguments.contains("DEVELOPMENT_TEAM=TEAM123"))
    }
    
    @Test("Build with derived data path includes it in arguments")
    func testBuildWithDerivedDataPath() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: "./DerivedData"
        )
        
        _ = try await executor.executeBuild(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-derivedDataPath"))
        #expect(arguments.contains("./DerivedData"))
    }
}

