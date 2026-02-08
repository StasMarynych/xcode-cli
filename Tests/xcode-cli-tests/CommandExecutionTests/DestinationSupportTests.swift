import Testing

@testable import xcode_cli

@Suite("Destination Support Tests")
struct DestinationSupportTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Simulator destination formats correctly")
    func testSimulatorDestination() {
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
        
        #expect(destinationValue.contains("platform=iOS Simulator"))
        #expect(destinationValue.contains("name=iPhone 15 Pro"))
        #expect(destinationValue.contains("OS=17.2"))
    }
    
    @Test("Device destination formats correctly")
    func testDeviceDestination() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .device(name: "My iPhone")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-destination"))
        let destinationIndex = arguments.firstIndex(of: "-destination")!
        let destinationValue = arguments[destinationIndex + 1]
        
        #expect(destinationValue.contains("platform=iOS"))
        #expect(destinationValue.contains("name=My iPhone"))
    }
    
    @Test("Generic platform destination formats correctly")
    func testGenericPlatformDestination() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .generic(platform: "iOS")
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
        
        #expect(arguments.contains("-destination"))
        let destinationIndex = arguments.firstIndex(of: "-destination")!
        let destinationValue = arguments[destinationIndex + 1]
        
        #expect(destinationValue.contains("generic/platform=iOS"))
    }
    
    @Test("Simulator destination with different OS versions")
    func testSimulatorWithDifferentOSVersions() {
        let osVersions = ["16.0", "17.0", "17.2", "18.0"]
        
        for osVersion in osVersions {
            let config = Configuration(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                buildConfiguration: "Release",
                destination: .simulator(name: "iPhone 15", os: osVersion)
            )
            
            let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
            let destinationIndex = arguments.firstIndex(of: "-destination")!
            let destinationValue = arguments[destinationIndex + 1]
            
            #expect(destinationValue.contains("OS=\(osVersion)"))
        }
    }
    
    @Test("Simulator destination with different device names")
    func testSimulatorWithDifferentDeviceNames() {
        let deviceNames = ["iPhone 15", "iPhone 15 Pro", "iPhone 15 Pro Max", "iPad Pro"]
        
        for deviceName in deviceNames {
            let config = Configuration(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                buildConfiguration: "Release",
                destination: .simulator(name: deviceName, os: "17.0")
            )
            
            let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
            let destinationIndex = arguments.firstIndex(of: "-destination")!
            let destinationValue = arguments[destinationIndex + 1]
            
            #expect(destinationValue.contains("name=\(deviceName)"))
        }
    }
    
    @Test("Device destination with different device names")
    func testDeviceWithDifferentNames() {
        let deviceNames = ["John's iPhone", "Test Device", "iPad Mini"]
        
        for deviceName in deviceNames {
            let config = Configuration(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                buildConfiguration: "Release",
                destination: .device(name: deviceName)
            )
            
            let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
            let destinationIndex = arguments.firstIndex(of: "-destination")!
            let destinationValue = arguments[destinationIndex + 1]
            
            #expect(destinationValue.contains("name=\(deviceName)"))
            #expect(destinationValue.contains("platform=iOS"))
        }
    }
    
    @Test("Generic platform with different platforms")
    func testGenericPlatformWithDifferentPlatforms() {
        let platforms = ["iOS", "macOS", "tvOS", "watchOS"]
        
        for platform in platforms {
            let config = Configuration(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                buildConfiguration: "Release",
                destination: .generic(platform: platform)
            )
            
            let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
            let destinationIndex = arguments.firstIndex(of: "-destination")!
            let destinationValue = arguments[destinationIndex + 1]
            
            #expect(destinationValue.contains("generic/platform=\(platform)"))
        }
    }
    
    @Test("Destination argument is always present")
    func testDestinationAlwaysPresent() {
        let destinations: [Destination] = [
            .simulator(name: "iPhone 15", os: "17.0"),
            .device(name: "My Device"),
            .generic(platform: "iOS"),
        ]
        
        for destination in destinations {
            let config = Configuration(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                buildConfiguration: "Release",
                destination: destination
            )
            
            let arguments = executor.buildXcodeBuildArguments(action: .build, config: config)
            
            #expect(arguments.contains("-destination"))
            
            let destinationIndex = arguments.firstIndex(of: "-destination")!
            #expect(destinationIndex + 1 < arguments.count)
            #expect(!arguments[destinationIndex + 1].isEmpty)
        }
    }
}
