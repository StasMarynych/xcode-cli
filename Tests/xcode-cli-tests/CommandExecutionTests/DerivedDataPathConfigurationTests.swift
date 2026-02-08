import Testing

@testable import xcode_cli

@Suite("Derived Data Path Configuration Tests")
struct DerivedDataPathConfigurationTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Build arguments include derivedDataPath when buildOutputPath is specified")
    func testDerivedDataPathIncluded() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: "/custom/DerivedData"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-derivedDataPath"))
        
        if let index = arguments.firstIndex(of: "-derivedDataPath") {
            #expect(arguments[index + 1] == "/custom/DerivedData")
        }
    }
    
    @Test("Build arguments exclude derivedDataPath when buildOutputPath is nil")
    func testDerivedDataPathExcludedWhenNil() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: nil
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(!arguments.contains("-derivedDataPath"))
    }
    
    @Test("Test arguments include derivedDataPath when buildOutputPath is specified")
    func testDerivedDataPathInTestCommand() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: "/test/DerivedData"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-derivedDataPath"))
        
        if let index = arguments.firstIndex(of: "-derivedDataPath") {
            #expect(arguments[index + 1] == "/test/DerivedData")
        }
    }
    
    @Test("Archive arguments include derivedDataPath when buildOutputPath is specified")
    func testDerivedDataPathInArchiveCommand() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            archivePath: "/output/MyApp.xcarchive",
            buildOutputPath: "/archive/DerivedData"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        #expect(arguments.contains("-derivedDataPath"))
        
        if let index = arguments.firstIndex(of: "-derivedDataPath") {
            #expect(arguments[index + 1] == "/archive/DerivedData")
        }
    }
    
    @Test("Derived data path with relative path")
    func testDerivedDataPathRelative() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: "./build/DerivedData"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-derivedDataPath"))
        
        if let index = arguments.firstIndex(of: "-derivedDataPath") {
            #expect(arguments[index + 1] == "./build/DerivedData")
        }
    }
    
    @Test("Derived data path with absolute path")
    func testDerivedDataPathAbsolute() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: "/Users/developer/MyApp/DerivedData"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-derivedDataPath"))
        
        if let index = arguments.firstIndex(of: "-derivedDataPath") {
            #expect(arguments[index + 1] == "/Users/developer/MyApp/DerivedData")
        }
    }
    
    @Test("Derived data path with spaces in path")
    func testDerivedDataPathWithSpaces() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: "/path with spaces/DerivedData"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-derivedDataPath"))
        
        if let index = arguments.firstIndex(of: "-derivedDataPath") {
            #expect(arguments[index + 1] == "/path with spaces/DerivedData")
        }
    }
    
    @Test("Derived data path appears after action in arguments")
    func testDerivedDataPathPosition() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            buildOutputPath: "/custom/DerivedData"
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        if let derivedDataIndex = arguments.firstIndex(of: "-derivedDataPath"),
           let buildIndex = arguments.firstIndex(of: "build")
        {
            #expect(derivedDataIndex > buildIndex)
        }
    }
}
