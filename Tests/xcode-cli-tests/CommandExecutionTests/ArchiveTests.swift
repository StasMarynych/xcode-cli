import Testing

@testable import xcode_cli

@Suite("Archive Command Tests")
struct ArchiveTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test(
        "Archive arguments construction with various configurations",
        arguments: [
            (
                projectPath: "MyApp.xcodeproj" as String?, workspacePath: nil as String?,
                scheme: "MyScheme", config: "Release", archivePath: "./build/MyApp.xcarchive",
                signingStyle: "manual" as String?, identity: "Apple Distribution: My Company" as String?,
                teamID: "TEAM123" as String?, profileUUID: "profile-uuid-123" as String?,
                profileName: nil as String?, profilePath: nil as String?,
                derivedDataPath: nil as String?
            ),
            (
                projectPath: nil as String?, workspacePath: "MyApp.xcworkspace" as String?,
                scheme: "WorkspaceScheme", config: "AppStore", archivePath: "./archives/App.xcarchive",
                signingStyle: "automatic" as String?, identity: nil as String?,
                teamID: "AUTO123" as String?,
                profileUUID: nil as String?, profileName: nil as String?, profilePath: nil as String?,
                derivedDataPath: "./DerivedData" as String?
            ),
            (
                projectPath: "TestApp.xcodeproj" as String?, workspacePath: nil as String?,
                scheme: "TestScheme", config: "Release", archivePath: "./test.xcarchive",
                signingStyle: "manual" as String?, identity: "Apple Distribution" as String?,
                teamID: "TEST456" as String?, profileUUID: nil as String?,
                profileName: "MyApp Distribution Profile" as String?, profilePath: nil as String?,
                derivedDataPath: nil as String?
            ),
            (
                projectPath: "PathApp.xcodeproj" as String?, workspacePath: nil as String?,
                scheme: "PathScheme", config: "Release", archivePath: "./path.xcarchive",
                signingStyle: "manual" as String?, identity: "Apple Distribution" as String?,
                teamID: "PATH789" as String?, profileUUID: nil as String?, profileName: nil as String?,
                profilePath: "/path/to/profile.mobileprovision" as String?,
                derivedDataPath: nil as String?
            ),
        ]
    )
    func testArchiveArgumentsConstruction(
        projectPath: String?,
        workspacePath: String?,
        scheme: String,
        config: String,
        archivePath: String,
        signingStyle: String?,
        identity: String?,
        teamID: String?,
        profileUUID: String?,
        profileName: String?,
        profilePath: String?,
        derivedDataPath: String?
    ) {
        var signing: SigningConfiguration? = nil
        if let style = signingStyle {
            var profile: ProvisioningProfile? = nil
            if let uuid = profileUUID {
                profile = ProvisioningProfile(uuid: uuid)
            } else if let name = profileName {
                profile = ProvisioningProfile(name: name)
            } else if let path = profilePath {
                profile = ProvisioningProfile(path: path)
            }
            
            signing = SigningConfiguration(
                style: style == "automatic" ? .automatic : .manual,
                identity: identity,
                teamID: teamID,
                provisioningProfile: profile
            )
        }
        
        let configuration = Configuration(
            projectPath: projectPath,
            workspacePath: workspacePath,
            scheme: scheme,
            buildConfiguration: config,
            destination: .generic(platform: "iOS"),
            signing: signing,
            archivePath: archivePath,
            buildOutputPath: derivedDataPath
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: configuration)
        
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
        #expect(arguments.contains("archive"))
        #expect(arguments.contains("-archivePath"))
        #expect(arguments.contains(archivePath))
        
        if let style = signingStyle {
            #expect(arguments.contains("CODE_SIGN_STYLE=\(style)"))
            if let team = teamID {
                #expect(arguments.contains("DEVELOPMENT_TEAM=\(team)"))
            }
            if let id = identity {
                #expect(arguments.contains("CODE_SIGN_IDENTITY=\(id)"))
            }
            if let uuid = profileUUID {
                #expect(arguments.contains("PROVISIONING_PROFILE=\(uuid)"))
            } else if let name = profileName {
                #expect(arguments.contains("PROVISIONING_PROFILE_SPECIFIER=\(name)"))
            } else if let path = profilePath {
                #expect(arguments.contains("PROVISIONING_PROFILE=\(path)"))
            }
        }
        
        if let derivedData = derivedDataPath {
            #expect(arguments.contains("-derivedDataPath"))
            #expect(arguments.contains(derivedData))
        }
    }
    
    @Test("Archive arguments handle project vs workspace correctly")
    func testProjectWorkspaceSelection() {
        let projectConfig = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/MyApp.xcarchive"
        )
        
        let workspaceConfig = Configuration(
            workspacePath: "MyApp.xcworkspace",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/MyApp.xcarchive"
        )
        
        let projectArgs = executor.buildXcodeBuildArguments(action: .archive, config: projectConfig)
        #expect(projectArgs.contains("-project"))
        #expect(projectArgs.contains("MyApp.xcodeproj"))
        #expect(!projectArgs.contains("-workspace"))
        
        let workspaceArgs = executor.buildXcodeBuildArguments(
            action: .archive, config: workspaceConfig)
        #expect(workspaceArgs.contains("-workspace"))
        #expect(workspaceArgs.contains("MyApp.xcworkspace"))
        #expect(!workspaceArgs.contains("-project"))
    }
    
    @Test("Successful archive returns exit code 0")
    func testSuccessfulArchiveReturnsZero() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 0,
            stdout: "Archive succeeded",
            stderr: ""
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/Test.xcarchive"
        )
        
        let result = try await executor.executeArchive(config: config)
        
        #expect(result.exitCode == 0)
        #expect(result.isSuccess == true)
    }
    
    @Test("Failed archive returns non-zero exit code")
    func testFailedArchiveReturnsNonZero() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 65,
            stdout: "",
            stderr: "Archive failed: Code signing error"
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/Test.xcarchive"
        )
        
        let result = try await executor.executeArchive(config: config)
        
        #expect(result.exitCode != 0)
        #expect(result.isSuccess == false)
    }
    
    @Test("Archive execution calls xcodebuild with correct executable")
    func testArchiveCallsXcodebuild() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/Test.xcarchive"
        )
        
        _ = try await executor.executeArchive(config: config)
        
        #expect(mockRunner.lastExecutable == "xcodebuild")
    }
    
    @Test("Archive execution streams output")
    func testArchiveStreamsOutput() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/Test.xcarchive"
        )
        
        _ = try await executor.executeArchive(config: config)
        
        #expect(mockRunner.lastStreamOutput == true)
    }
    
    @Test("Archive execution passes correct arguments")
    func testArchivePassesCorrectArguments() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./archives/MyApp.xcarchive"
        )
        
        _ = try await executor.executeArchive(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-project"))
        #expect(arguments.contains("MyApp.xcodeproj"))
        #expect(arguments.contains("-scheme"))
        #expect(arguments.contains("MyScheme"))
        #expect(arguments.contains("-configuration"))
        #expect(arguments.contains("Release"))
        #expect(arguments.contains("archive"))
        #expect(arguments.contains("-archivePath"))
        #expect(arguments.contains("./archives/MyApp.xcarchive"))
    }
    
    @Test("Archive with signing parameters includes them in arguments")
    func testArchiveWithSigningParameters() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let signing = SigningConfiguration(
            style: .manual,
            identity: "Apple Distribution",
            teamID: "TEAM123",
            provisioningProfile: ProvisioningProfile(uuid: "profile-uuid")
        )
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            signing: signing,
            archivePath: "./build/Test.xcarchive"
        )
        
        _ = try await executor.executeArchive(config: config)
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("CODE_SIGN_STYLE=manual"))
        #expect(arguments.contains("CODE_SIGN_IDENTITY=Apple Distribution"))
        #expect(arguments.contains("DEVELOPMENT_TEAM=TEAM123"))
        #expect(arguments.contains("PROVISIONING_PROFILE=profile-uuid"))
    }
    
    @Test("Successful export returns exit code 0")
    func testSuccessfulExportReturnsZero() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 0,
            stdout: "Export succeeded",
            stderr: ""
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./build/export"
        )
        
        let result = try await executor.executeExport(
            archivePath: "./build/Test.xcarchive",
            config: config
        )
        
        #expect(result.exitCode == 0)
        #expect(result.isSuccess == true)
    }
    
    @Test("Failed export returns non-zero exit code")
    func testFailedExportReturnsNonZero() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 70,
            stdout: "",
            stderr: "Export failed: Invalid export options"
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./build/export"
        )
        
        let result = try await executor.executeExport(
            archivePath: "./build/Test.xcarchive",
            config: config
        )
        
        #expect(result.exitCode != 0)
        #expect(result.isSuccess == false)
    }
    
    @Test("Export execution calls xcodebuild with correct executable")
    func testExportCallsXcodebuild() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./build/export"
        )
        
        _ = try await executor.executeExport(
            archivePath: "./build/Test.xcarchive",
            config: config
        )
        
        #expect(mockRunner.lastExecutable == "xcodebuild")
    }
    
    @Test("Export execution streams output")
    func testExportStreamsOutput() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./build/export"
        )
        
        _ = try await executor.executeExport(
            archivePath: "./build/Test.xcarchive",
            config: config
        )
        
        #expect(mockRunner.lastStreamOutput == true)
    }
    
    @Test("Export execution passes correct arguments")
    func testExportPassesCorrectArguments() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./exports",
            exportOptionsPlist: "./ExportOptions.plist"
        )
        
        _ = try await executor.executeExport(
            archivePath: "./archives/MyApp.xcarchive",
            config: config
        )
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-exportArchive"))
        #expect(arguments.contains("-archivePath"))
        #expect(arguments.contains("./archives/MyApp.xcarchive"))
        #expect(arguments.contains("-exportPath"))
        #expect(arguments.contains("./exports"))
        #expect(arguments.contains("-exportOptionsPlist"))
        #expect(arguments.contains("./ExportOptions.plist"))
    }
    
    @Test("Export with different archive paths")
    func testExportWithDifferentArchivePaths() async throws {
        let mockRunner = MockProcessRunnerCapture()
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./exports"
        )
        
        _ = try await executor.executeExport(
            archivePath: "/absolute/path/Test.xcarchive",
            config: config
        )
        
        let arguments = mockRunner.lastArguments
        #expect(arguments.contains("-archivePath"))
        #expect(arguments.contains("/absolute/path/Test.xcarchive"))
    }
    
    @Test("Archive failure with detailed error message")
    func testArchiveFailureWithDetailedError() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 65,
            stdout: "** ARCHIVE FAILED **",
            stderr: "error: Provisioning profile not found"
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/Test.xcarchive"
        )
        
        let result = try await executor.executeArchive(config: config)
        
        #expect(result.exitCode == 65)
        #expect(result.stderr.contains("Provisioning profile not found"))
    }
    
    @Test("Export failure with detailed error message")
    func testExportFailureWithDetailedError() async throws {
        let mockRunner = MockProcessRunnerWithResult(
            exitCode: 70,
            stdout: "** EXPORT FAILED **",
            stderr: "error: Invalid export method specified"
        )
        let executor = CommandExecutor(processRunner: mockRunner)
        
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./exports"
        )
        
        let result = try await executor.executeExport(
            archivePath: "./build/Test.xcarchive",
            config: config
        )
        
        #expect(result.exitCode == 70)
        #expect(result.stderr.contains("Invalid export method specified"))
    }
}
