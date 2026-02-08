import Testing

@testable import xcode_cli

@Suite("Parallel Testing Configuration Tests")
struct ParallelTestingTests {
    let executor = CommandExecutor(processRunner: MockProcessRunner())
    
    @Test("Parallel testing enabled includes correct flags")
    func testParallelTestingEnabledIncludesFlags() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            parallelTesting: true
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-parallel-testing-enabled"))
        #expect(arguments.contains("YES"))
    }
    
    @Test("Parallel testing with worker count includes worker count flag")
    func testParallelTestingWithWorkerCount() {
        let workerCounts = [2, 4, 8, 16]
        
        for workers in workerCounts {
            let config = Configuration(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                buildConfiguration: "Release",
                destination: .simulator(name: "iPhone 15", os: "17.0"),
                parallelTesting: true,
                parallelTestingWorkers: workers
            )
            
            let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
            
            #expect(arguments.contains("-parallel-testing-enabled"))
            #expect(arguments.contains("YES"))
            #expect(arguments.contains("-parallel-testing-worker-count"))
            #expect(arguments.contains("\(workers)"))
        }
    }
    
    @Test("Parallel testing disabled does not include flags")
    func testParallelTestingDisabledDoesNotIncludeFlags() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            parallelTesting: false
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(!arguments.contains("-parallel-testing-enabled"))
        #expect(!arguments.contains("-parallel-testing-worker-count"))
    }
    
    @Test("Parallel testing enabled without worker count omits worker count flag")
    func testParallelTestingWithoutWorkerCount() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            parallelTesting: true,
            parallelTestingWorkers: nil
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-parallel-testing-enabled"))
        #expect(arguments.contains("YES"))
        #expect(!arguments.contains("-parallel-testing-worker-count"))
    }
    
    @Test("Parallel testing flags appear after test action")
    func testParallelTestingFlagsOrder() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Release",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            parallelTesting: true,
            parallelTestingWorkers: 4
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        let testIndex = arguments.firstIndex(of: "test")!
        let parallelEnabledIndex = arguments.firstIndex(of: "-parallel-testing-enabled")!
        
        #expect(parallelEnabledIndex > testIndex)
    }
    
    @Test("Parallel testing with multiple configurations")
    func testParallelTestingWithMultipleConfigurations() {
        let configs = [
            (enabled: true, workers: 2),
            (enabled: true, workers: 4),
            (enabled: true, workers: 8),
            (enabled: false, workers: nil as Int?),
        ]
        
        for (enabled, workers) in configs {
            let config = Configuration(
                projectPath: "Test.xcodeproj",
                scheme: "TestScheme",
                buildConfiguration: "Release",
                destination: .simulator(name: "iPhone 15", os: "17.0"),
                parallelTesting: enabled,
                parallelTestingWorkers: workers
            )
            
            let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
            
            if enabled {
                #expect(arguments.contains("-parallel-testing-enabled"))
                #expect(arguments.contains("YES"))
                
                if let workers = workers {
                    #expect(arguments.contains("-parallel-testing-worker-count"))
                    #expect(arguments.contains("\(workers)"))
                } else {
                    #expect(!arguments.contains("-parallel-testing-worker-count"))
                }
            } else {
                #expect(!arguments.contains("-parallel-testing-enabled"))
                #expect(!arguments.contains("-parallel-testing-worker-count"))
            }
        }
    }
    
    @Test("Parallel testing preserves other test arguments")
    func testParallelTestingPreservesOtherArguments() {
        let config = Configuration(
            projectPath: "Test.xcodeproj",
            scheme: "TestScheme",
            buildConfiguration: "Debug",
            destination: .simulator(name: "iPhone 15", os: "17.0"),
            testTargets: ["MyAppTests"],
            parallelTesting: true,
            parallelTestingWorkers: 4
        )
        
        let arguments = executor.buildXcodeBuildArguments(action: .test, config: config)
        
        #expect(arguments.contains("-project"))
        #expect(arguments.contains("Test.xcodeproj"))
        #expect(arguments.contains("-scheme"))
        #expect(arguments.contains("TestScheme"))
        #expect(arguments.contains("-configuration"))
        #expect(arguments.contains("Debug"))
        #expect(arguments.contains("test"))
        #expect(arguments.contains("-only-testing"))
        #expect(arguments.contains("MyAppTests"))
    }
}
