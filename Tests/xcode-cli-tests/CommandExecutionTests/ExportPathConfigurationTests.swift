import Testing

@testable import xcode_cli

@Suite("Export Path Configuration Tests")
struct ExportPathConfigurationTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Export arguments include exportPath when specified")
    func testExportPathIncluded() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "/output/IPA"
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: "/archive/MyApp.xcarchive",
            config: config
        )
        
        #expect(arguments.contains("-exportPath"))
        
        if let index = arguments.firstIndex(of: "-exportPath") {
            #expect(arguments[index + 1] == "/output/IPA")
        }
    }
    
    @Test("Export arguments exclude exportPath when nil")
    func testExportPathExcludedWhenNil() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: nil
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: "/archive/MyApp.xcarchive",
            config: config
        )
        
        #expect(!arguments.contains("-exportPath"))
    }
    
    @Test("Export path with relative path")
    func testExportPathRelative() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./build/IPA"
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: "/archive/MyApp.xcarchive",
            config: config
        )
        
        #expect(arguments.contains("-exportPath"))
        
        if let index = arguments.firstIndex(of: "-exportPath") {
            #expect(arguments[index + 1] == "./build/IPA")
        }
    }
    
    @Test("Export path with absolute path")
    func testExportPathAbsolute() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "/Users/developer/Exports/IPA"
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: "/archive/MyApp.xcarchive",
            config: config
        )
        
        #expect(arguments.contains("-exportPath"))
        
        if let index = arguments.firstIndex(of: "-exportPath") {
            #expect(arguments[index + 1] == "/Users/developer/Exports/IPA")
        }
    }
    
    @Test("Export path with spaces in path")
    func testExportPathWithSpaces() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "/path with spaces/IPA"
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: "/archive/MyApp.xcarchive",
            config: config
        )
        
        #expect(arguments.contains("-exportPath"))
        
        if let index = arguments.firstIndex(of: "-exportPath") {
            #expect(arguments[index + 1] == "/path with spaces/IPA")
        }
    }
    
    @Test("Export arguments include archivePath")
    func testExportIncludesArchivePath() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "/output/IPA"
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: "/custom/MyApp.xcarchive",
            config: config
        )
        
        #expect(arguments.contains("-archivePath"))
        
        if let index = arguments.firstIndex(of: "-archivePath") {
            #expect(arguments[index + 1] == "/custom/MyApp.xcarchive")
        }
    }
    
    @Test("Export arguments include exportArchive action")
    func testExportIncludesExportArchiveAction() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "/output/IPA"
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: "/archive/MyApp.xcarchive",
            config: config
        )
        
        #expect(arguments.contains("-exportArchive"))
    }
    
    @Test("Export path appears after archivePath in arguments")
    func testExportPathPosition() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "/output/IPA"
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: "/archive/MyApp.xcarchive",
            config: config
        )
        
        if let exportPathIndex = arguments.firstIndex(of: "-exportPath"),
           let archivePathIndex = arguments.firstIndex(of: "-archivePath")
        {
            #expect(exportPathIndex > archivePathIndex)
        }
    }
}
