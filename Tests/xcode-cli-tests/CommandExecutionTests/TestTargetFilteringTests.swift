import Testing

@testable import xcode_cli

@Suite("Test Target Filtering Tests")
struct TestTargetFilteringTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Test arguments include only-testing for each specified target")
    func testArgumentsIncludeOnlyTestingForEachTarget() {
        let testTargets = [
            ["MyAppTests"],
            ["MyAppTests", "MyAppUITests"],
            ["UnitTests", "IntegrationTests", "UITests"],
        ]
        
        for targets in testTargets {
            let config = Configuration(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                buildConfiguration: "Release",
                destination: .simulator(name: "iPhone 15", os: "17.0"),
                testTargets: targets
            )
            
            let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
            
            for target in targets {
                #expect(arguments.contains("-only-testing"))
                #expect(arguments.contains(target))
                
                if let onlyTestingIndex = arguments.firstIndex(of: "-only-testing") {
                    let nextIndex = onlyTestingIndex + 1
                    if nextIndex < arguments.count {
                        let nextValue = arguments[nextIndex]
                        #expect(targets.contains(nextValue))
                    }
                }
            }
            
            let onlyTestingCount = arguments.filter { $0 == "-only-testing" }.count
            #expect(onlyTestingCount == targets.count)
        }
    }
    
    @Test("Test arguments with single test target")
    func testArgumentsWithSingleTestTarget() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            testTargets: ["MyAppTests"]
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-only-testing"))
        #expect(arguments.contains("MyAppTests"))
        
        let onlyTestingCount = arguments.filter { $0 == "-only-testing" }.count
        #expect(onlyTestingCount == 1)
    }
    
    @Test("Test arguments with multiple test targets")
    func testArgumentsWithMultipleTestTargets() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            testTargets: ["MyAppTests", "MyAppUITests", "MyAppIntegrationTests"]
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-only-testing"))
        #expect(arguments.contains("MyAppTests"))
        #expect(arguments.contains("MyAppUITests"))
        #expect(arguments.contains("MyAppIntegrationTests"))
        
        let onlyTestingCount = arguments.filter { $0 == "-only-testing" }.count
        #expect(onlyTestingCount == 3)
    }
    
    @Test("Test arguments without test targets do not include only-testing")
    func testArgumentsWithoutTestTargets() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            testTargets: []
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(!arguments.contains("-only-testing"))
    }
    
    @Test("Test arguments with empty test targets array")
    func testArgumentsWithEmptyTestTargets() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            testTargets: []
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        let onlyTestingCount = arguments.filter { $0 == "-only-testing" }.count
        #expect(onlyTestingCount == 0)
    }
    
    @Test("Test target filtering preserves other arguments")
    func testTargetFilteringPreservesOtherArguments() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            testTargets: ["MyAppTests"]
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-project"))
        #expect(arguments.contains("Test.xcodeproj"))
        #expect(arguments.contains("-scheme"))
        #expect(arguments.contains("TestScheme"))
        #expect(arguments.contains("-configuration"))
        #expect(arguments.contains("Debug"))
        #expect(arguments.contains("test"))
    }
}
