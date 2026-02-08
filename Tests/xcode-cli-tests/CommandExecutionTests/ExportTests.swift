import Testing

@testable import xcode_cli

@Suite("Export Command Argument Construction Tests")
struct ExportCommandArgumentTests {
    
    @Test(
        "Export arguments construction with various configurations",
        arguments: [
            (
                archivePath: "./build/MyApp.xcarchive", exportPath: "./build/export" as String?,
                exportOptionsPlist: nil as String?
            ),
            (
                archivePath: "./archives/MyApp.xcarchive", exportPath: "./output/ipa" as String?,
                exportOptionsPlist: "./ExportOptions.plist" as String?
            ),
            (
                archivePath: "/absolute/path/App2.xcarchive",
                exportPath: "/absolute/export/path" as String?,
                exportOptionsPlist: "/absolute/path/ExportOptions.plist" as String?
            ),
            (
                archivePath: "relative/App3.xcarchive", exportPath: nil as String?,
                exportOptionsPlist: nil as String?
            ),
            (
                archivePath: "./archives/Complete.xcarchive",
                exportPath: "./exports/complete" as String?,
                exportOptionsPlist: "./config/ExportOptions.plist" as String?
            ),
        ]
    )
    func testExportArgumentsConstruction(
        archivePath: String,
        exportPath: String?,
        exportOptionsPlist: String?
    ) {
        let executor = CommandExecutor(processRunner: MockProcessRunner())
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: exportPath,
            exportMethod: exportPath != nil ? .appStore : nil,
            exportOptionsPlist: exportOptionsPlist
        )
        
        let arguments = executor.buildExportArguments(
            archivePath: archivePath,
            config: config
        )
        
        #expect(arguments.contains("-exportArchive"))
        #expect(arguments.contains("-archivePath"))
        #expect(arguments.contains(archivePath))
        
        if let export = exportPath {
            #expect(arguments.contains("-exportPath"))
            #expect(arguments.contains(export))
        } else {
            #expect(!arguments.contains("-exportPath"))
        }
        
        if let plist = exportOptionsPlist {
            #expect(arguments.contains("-exportOptionsPlist"))
            #expect(arguments.contains(plist))
        } else {
            #expect(!arguments.contains("-exportOptionsPlist"))
        }
    }
    
    @Test("Export arguments handle optional parameters correctly")
    func testOptionalParameters() {
        let executor = CommandExecutor(processRunner: MockProcessRunner())
        
        let withAllParams = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./exports",
            exportOptionsPlist: "./ExportOptions.plist"
        )
        
        let withoutExportPath = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS")
        )
        
        let withoutPlist = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS"),
            exportPath: "./build/export"
        )
        
        let allArgs = executor.buildExportArguments(
            archivePath: "./build/MyApp.xcarchive",
            config: withAllParams
        )
        #expect(allArgs.contains("-exportPath"))
        #expect(allArgs.contains("-exportOptionsPlist"))
        
        let noExportPathArgs = executor.buildExportArguments(
            archivePath: "./build/MyApp.xcarchive",
            config: withoutExportPath
        )
        #expect(!noExportPathArgs.contains("-exportPath"))
        
        let noPlistArgs = executor.buildExportArguments(
            archivePath: "./build/MyApp.xcarchive",
            config: withoutPlist
        )
        #expect(noPlistArgs.contains("-exportPath"))
        #expect(!noPlistArgs.contains("-exportOptionsPlist"))
    }
}
