import Testing

@testable import xcode_cli

@Suite("Test Command Tests")
struct TestTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test(
        "Test arguments construction with various configurations",
        arguments: [
            (
                projectPath: "MyApp.xcodeproj" as String?, workspacePath: nil as String?,
                scheme: "MyScheme", config: "Debug", deviceName: "iPhone 15", os: "17.0"
            ),
            (
                projectPath: "TestApp.xcodeproj" as String?, workspacePath: nil as String?,
                scheme: "TestScheme", config: "Release", deviceName: "iPhone 15 Pro", os: "17.2"
            ),
            (
                projectPath: nil as String?, workspacePath: "MyApp.xcworkspace" as String?,
                scheme: "WorkspaceScheme", config: "Debug", deviceName: "iPhone 15", os: "17.0"
            ),
            (
                projectPath: nil as String?, workspacePath: "TestApp.xcworkspace" as String?,
                scheme: "AnotherScheme", config: "Release", deviceName: "iPhone 14", os: "16.0"
            ),
        ]
    )
    func testArgumentsConstruction(
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
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: configuration)
        
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
        #expect(arguments.contains("test"))
        
        let destinationIndex = arguments.firstIndex(of: "-destination")!
        let destinationValue = arguments[destinationIndex + 1]
        #expect(destinationValue.contains(deviceName))
        #expect(destinationValue.contains(os))
    }
    
    @Test("Test arguments handle project vs workspace correctly")
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
        
        let projectArgs = executor.buildXcodeBuildArguments(action: .test, config: projectConfig)
        #expect(projectArgs.contains("-project"))
        #expect(projectArgs.contains("MyApp.xcodeproj"))
        #expect(!projectArgs.contains("-workspace"))
        
        let workspaceArgs = executor.buildXcodeBuildArguments(action: .test, config: workspaceConfig)
        #expect(workspaceArgs.contains("-workspace"))
        #expect(workspaceArgs.contains("MyApp.xcworkspace"))
        #expect(!workspaceArgs.contains("-project"))
    }
    
    @Test("Passing tests return exit code 0")
    func testPassingTestsReturnZero() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 0,
            stdout: "Test Suite 'All tests' passed",
            stderr: ""
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeTest(config: config)
        
        #expect(result.exitCode == 0)
        #expect(result.isSuccess == true)
    }
    
    @Test("Failing tests return non-zero exit code")
    func testFailingTestsReturnNonZero() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 1,
            stdout: "",
            stderr: "Test Suite 'All tests' failed"
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let result = try await executor.executeTest(config: config)
        
        #expect(result.exitCode != 0)
        #expect(result.isSuccess == false)
    }
    
    @Test("Test execution calls xcodebuild with correct executable")
    func testExecutionCallsXcodebuild() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        _ = try await executor.executeTest(config: config)
        
        #expect(mockRunner.lastExecutable == "xcodebuild")
    }
    
    @Test("Test execution streams output")
    func testExecutionStreamsOutput() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        _ = try await executor.executeTest(config: config)
        
        #expect(mockRunner.lastStreamOutput == true)
    }
    
    @Test("Test execution passes correct arguments")
    func testExecutionPassesCorrectArguments() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15 Pro", os: "17.2")
        )
        
        _ = try await executor.executeTest(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-project"))
        #expect(arguments.contains("MyApp.xcodeproj"))
        #expect(arguments.contains("-scheme"))
        #expect(arguments.contains("MyScheme"))
        #expect(arguments.contains("-configuration"))
        #expect(arguments.contains("Debug"))
        #expect(arguments.contains("test"))
    }
    
    @Test("Test execution with workspace uses workspace argument")
    func testExecutionWithWorkspace() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        _ = try await executor.executeTest(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-workspace"))
        #expect(arguments.contains("MyApp.xcworkspace"))
        #expect(!arguments.contains("-project"))
    }
    
    @Test("Test execution with test targets includes only-testing flags")
    func testExecutionWithTestTargets() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            testTargets: ["MyAppTests", "MyAppUITests"]
        )
        
        _ = try await executor.executeTest(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-only-testing"))
        #expect(arguments.contains("MyAppTests"))
        #expect(arguments.contains("MyAppUITests"))
    }
    
    @Test("Test execution with parallel testing includes parallel flags")
    func testExecutionWithParallelTesting() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            parallelTesting: true,
            parallelTestingWorkers: 4
        )
        
        _ = try await executor.executeTest(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-parallel-testing-enabled"))
        #expect(arguments.contains("YES"))
        #expect(arguments.contains("-parallel-testing-worker-count"))
        #expect(arguments.contains("4"))
    }
    
    @Test("Test execution with signing parameters includes them in arguments")
    func testExecutionWithSigningParameters() async throws {
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
        
        _ = try await executor.executeTest(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
        #expect(arguments.contains("CODE_SIGN_IDENTITY=Apple Distribution"))
        #expect(arguments.contains("DEVELOPMENT_TEAM=TEAM123"))
    }
    
    @Test("Test execution with derived data path includes it in arguments")
    func testExecutionWithDerivedDataPath() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: "./DerivedData"
        )
        
        _ = try await executor.executeTest(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-derivedDataPath"))
        #expect(arguments.contains("./DerivedData"))
    }
}
