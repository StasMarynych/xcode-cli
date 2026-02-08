import Testing

@testable import xcode_cli

@Suite("Multiple Destination Handling Tests")
struct MultipleDestinationHandlingTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    // Note: The current Configuration model only supports a single destination.
    // These tests validate the current single-destination behavior.
    // When multiple destinations are implemented, the Configuration model will need
    // to be updated to support an array of destinations, and these tests will need
    // to be updated accordingly.
    
    @Test("Single simulator destination generates correct arguments")
    func testSingleSimulatorDestination() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-destination"))
        
        let destinationCount = arguments.filter { $0 == "-destination" }.count
        #expect(destinationCount == 1)
        
        if let index = arguments.firstIndex(of: "-destination") {
            let destinationValue = arguments[index + 1]
            #expect(destinationValue.contains("iPhone 15"))
            #expect(destinationValue.contains("17.0"))
        }
    }
    
    @Test("Single device destination generates correct arguments")
    func testSingleDeviceDestination() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .device(name: "My iPhone")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-destination"))
        
        let destinationCount = arguments.filter { $0 == "-destination" }.count
        #expect(destinationCount == 1)
        
        if let index = arguments.firstIndex(of: "-destination") {
            let destinationValue = arguments[index + 1]
            #expect(destinationValue.contains("My iPhone"))
        }
    }
    
    @Test("Generic platform destination generates correct arguments")
    func testGenericPlatformDestination() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        #expect(arguments.contains("-destination"))
        
        let destinationCount = arguments.filter { $0 == "-destination" }.count
        #expect(destinationCount == 1)
        
        if let index = arguments.firstIndex(of: "-destination") {
            let destinationValue = arguments[index + 1]
            #expect(destinationValue.contains("generic/platform=iOS"))
        }
    }
    
    @Test("Destination is included in all action types")
    func testDestinationInAllActions() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            archivePath: "/output/MyApp.xcarchive"
        )
        
        let buildArgs = executor.buildXcodeBuildArguments(action: .build, config: config)
        #expect(buildArgs.contains("-destination"))
        
        let testArgs = executor.buildXcodeBuildArguments(action: .test, config: config)
        #expect(testArgs.contains("-destination"))
        
        let archiveArgs = executor.buildXcodeBuildArguments(action: .archive, config: config)
        #expect(archiveArgs.contains("-destination"))
    }
    
    @Test("Destination format for simulator includes platform, name, and OS")
    func testSimulatorDestinationFormat() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15 Pro", os: "17.2")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        if let index = arguments.firstIndex(of: "-destination") {
            let destinationValue = arguments[index + 1]
            #expect(destinationValue.contains("platform=iOS Simulator"))
            #expect(destinationValue.contains("name=iPhone 15 Pro"))
            #expect(destinationValue.contains("OS=17.2"))
        }
    }
    
    @Test("Destination format for device includes platform and name")
    func testDeviceDestinationFormat() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .device(name: "John's iPhone")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        if let index = arguments.firstIndex(of: "-destination") {
            let destinationValue = arguments[index + 1]
            #expect(destinationValue.contains("platform=iOS"))
            #expect(destinationValue.contains("name=John's iPhone"))
        }
    }
    
    @Test("Destination format for generic platform")
    func testGenericPlatformDestinationFormat() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .archive, config: config)
        
        if let index = arguments.firstIndex(of: "-destination") {
            let destinationValue = arguments[index + 1]
            #expect(destinationValue == "generic/platform=iOS")
        }
    }
}
