import Testing

@testable import xcode_cli

@Suite("Archive Path Configuration Tests")
struct ArchivePathConfigurationTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Archive arguments include archivePath when specified")
    func testArchivePathIncluded() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "/output/MyApp.xcarchive"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        #expect(arguments.contains("-archivePath"))
        
        if let index = arguments.firstIndex(of: "-archivePath") {
            #expect(arguments[index + 1] == "/output/MyApp.xcarchive")
        }
    }
    
    @Test("Archive arguments exclude archivePath when nil")
    func testArchivePathExcludedWhenNil() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: nil
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        #expect(!arguments.contains("-archivePath"))
    }
    
    @Test("Build action does not include archivePath even when specified")
    func testArchivePathNotInBuildAction() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            archivePath: "/output/MyApp.xcarchive"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(!arguments.contains("-archivePath"))
    }
    
    @Test("Test action does not include archivePath even when specified")
    func testArchivePathNotInTestAction() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            archivePath: "/output/MyApp.xcarchive"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(!arguments.contains("-archivePath"))
    }
    
    @Test("Archive path with relative path")
    func testArchivePathRelative() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "./build/MyApp.xcarchive"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        #expect(arguments.contains("-archivePath"))
        
        if let index = arguments.firstIndex(of: "-archivePath") {
            #expect(arguments[index + 1] == "./build/MyApp.xcarchive")
        }
    }
    
    @Test("Archive path with absolute path")
    func testArchivePathAbsolute() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "/Users/developer/Archives/MyApp.xcarchive"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        #expect(arguments.contains("-archivePath"))
        
        if let index = arguments.firstIndex(of: "-archivePath") {
            #expect(arguments[index + 1] == "/Users/developer/Archives/MyApp.xcarchive")
        }
    }
    
    @Test("Archive path with spaces in path")
    func testArchivePathWithSpaces() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "/path with spaces/MyApp.xcarchive"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        #expect(arguments.contains("-archivePath"))
        
        if let index = arguments.firstIndex(of: "-archivePath") {
            #expect(arguments[index + 1] == "/path with spaces/MyApp.xcarchive")
        }
    }
    
    @Test("Archive path appears after archive action in arguments")
    func testArchivePathPosition() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "/output/MyApp.xcarchive"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        if let archivePathIndex = arguments.firstIndex(of: "-archivePath"),
           let archiveActionIndex = arguments.firstIndex(of: "archive")
        {
            #expect(archivePathIndex > archiveActionIndex)
        }
    }
}
