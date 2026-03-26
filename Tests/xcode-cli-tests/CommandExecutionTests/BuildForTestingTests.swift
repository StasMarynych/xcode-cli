import Testing

@testable import xcode_cli

@Suite("Build For Testing Argument Tests")
struct BuildForTestingTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())

    @Test("build-for-testing action token appears in arguments")
    func testBuildForTestingActionToken() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )

        let arguments = executor.buildXcodeBuildArguments(action: .buildForTesting, config: config)

        #expect(arguments.contains("build-for-testing"))
        #expect(!arguments.contains("test-without-building"))
    }

    @Test("test-without-building action token appears in arguments")
    func testTestWithoutBuildingActionToken() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0")
        )

        let arguments = executor.buildXcodeBuildArguments(action: .testWithoutBuilding, config: config)

        #expect(arguments.contains("test-without-building"))
        #expect(!arguments.contains("build-for-testing"))
    }

    @Test("test-without-building includes -only-testing flags for each test target")
    func testTestWithoutBuildingIncludesOnlyTestingFlags() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            testTargets: ["MyAppTests", "MyAppUITests"]
        )

        let arguments = executor.buildXcodeBuildArguments(action: .testWithoutBuilding, config: config)

        #expect(arguments.contains("-only-testing"))
        #expect(arguments.contains("MyAppTests"))
        #expect(arguments.contains("MyAppUITests"))
    }

    @Test("test-without-building includes -parallel-testing-enabled YES when parallelTesting is true")
    func testTestWithoutBuildingIncludesParallelTestingFlag() {
        let config = Configuration(
            projectPath: "MyApp.xcodeproj",
            scheme: "MyScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            parallelTesting: true
        )

        let arguments = executor.buildXcodeBuildArguments(action: .testWithoutBuilding, config: config)

        #expect(arguments.contains("-parallel-testing-enabled"))
        #expect(arguments.contains("YES"))
    }
}
