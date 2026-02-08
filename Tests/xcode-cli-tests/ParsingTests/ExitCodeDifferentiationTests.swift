import Foundation
import Testing

@testable import xcode_cli

@Suite("Exit Code Differentiation Tests")
struct ExitCodeDifferentiationTests {
    
    @Test(
        "Exit code differentiation for configuration errors",
        arguments: [
            ConfigurationError.fileNotFound(path: "/test/path"),
            .invalidYAML(message: "test"),
            .missingRequiredField(field: "scheme"),
            .invalidFieldType(field: "test", expected: "string"),
            .conflictingFields(fields: ["project", "workspace"]),
            .missingProjectOrWorkspace,
            .bothProjectAndWorkspaceSpecified,
            .missingScheme,
            .invalidExportMethod(method: "invalid"),
            .missingSigningIdentity,
            .invalidParallelTestingWorkers(count: -1),
            .multipleProvisioningProfileFieldsSpecified,
            .invalidCodeSignStyle(style: "invalid"),
            .mergerError(message: "test"),
        ]
    )
    func exitCodeDifferentiationConfigurationErrors(configError: ConfigurationError) {
        let cliError = CLIError.configurationError(configError)
        #expect(
            cliError.exitCode == 1,
            "Configuration error should have exit code 1, got \(cliError.exitCode) for \(configError)"
        )
    }
    
    @Test(
        "Exit code differentiation for build errors",
        arguments: [
            BuildError.buildFailed(message: "test"),
            .compilationError(file: "test.swift", line: 10, message: "error"),
            .linkingError(message: "test"),
            .signingError(message: "test"),
        ]
    )
    func exitCodeDifferentiationBuildErrors(buildError: BuildError) {
        let cliError = CLIError.buildError(buildError)
        #expect(
            cliError.exitCode == 2,
            "Build error should have exit code 2, got \(cliError.exitCode) for \(buildError)"
        )
    }
    
    @Test("Exit code differentiation for build xcodebuild errors preserves exit code")
    func exitCodeDifferentiationBuildXcodebuildErrors() {
        // xcodebuildError should preserve the actual xcodebuild exit code
        let cliError = CLIError.buildError(.xcodebuildError(exitCode: 65, stderr: "test"))
        #expect(
            cliError.exitCode == 65,
            "Build xcodebuildError should preserve exit code 65, got \(cliError.exitCode)"
        )
        
        // Test with different exit code
        let cliError2 = CLIError.buildError(.xcodebuildError(exitCode: 1, stderr: "test"))
        #expect(
            cliError2.exitCode == 1,
            "Build xcodebuildError should preserve exit code 1, got \(cliError2.exitCode)"
        )
    }
    
    @Test(
        "Exit code differentiation for test errors",
        arguments: [
            TestError.testsFailed(message: "test"),
            .testExecutionError(message: "test"),
            .testTargetNotFound(target: "TestTarget"),
        ]
    )
    func exitCodeDifferentiationTestErrors(testError: TestError) {
        let cliError = CLIError.testError(testError)
        #expect(
            cliError.exitCode == 3,
            "Test error should have exit code 3, got \(cliError.exitCode) for \(testError)"
        )
    }
    
    @Test("Exit code differentiation for test xcodebuild errors preserves exit code")
    func exitCodeDifferentiationTestXcodebuildErrors() {
        // xcodebuildError should preserve the actual xcodebuild exit code
        let cliError = CLIError.testError(.xcodebuildError(exitCode: 65, stderr: "test"))
        #expect(
            cliError.exitCode == 65,
            "Test xcodebuildError should preserve exit code 65, got \(cliError.exitCode)"
        )
    }
    
    @Test(
        "Exit code differentiation for archive errors",
        arguments: [
            ArchiveError.archiveFailed(message: "test"),
            .exportFailed(message: "test"),
            .invalidArchivePath(path: "/test/path"),
            .missingExportOptions(message: "test"),
        ]
    )
    func exitCodeDifferentiationArchiveErrors(archiveError: ArchiveError) {
        let cliError = CLIError.archiveError(archiveError)
        #expect(
            cliError.exitCode == 4,
            "Archive error should have exit code 4, got \(cliError.exitCode) for \(archiveError)"
        )
    }
    
    @Test("Exit code differentiation for archive xcodebuild errors preserves exit code")
    func exitCodeDifferentiationArchiveXcodebuildErrors() {
        // xcodebuildError should preserve the actual xcodebuild exit code
        let cliError = CLIError.archiveError(.xcodebuildError(exitCode: 65, stderr: "test"))
        #expect(
            cliError.exitCode == 65,
            "Archive xcodebuildError should preserve exit code 65, got \(cliError.exitCode)"
        )
    }
    
    @Test(
        "Exit code differentiation for simulator errors",
        arguments: [
            SimulatorError.commandFailed(message: "test"),
            .bootFailed(deviceID: "test-id", reason: "test"),
            .shutdownFailed(deviceID: "test-id", reason: "test"),
            .deviceNotFound(identifier: "test"),
            .appInstallFailed(message: "test"),
            .appLaunchFailed(message: "test"),
            .simctlError(exitCode: 1, stderr: "test"),
        ]
    )
    func exitCodeDifferentiationSimulatorErrors(simError: SimulatorError) {
        let cliError = CLIError.simulatorError(simError)
        #expect(
            cliError.exitCode == 5,
            "Simulator error should have exit code 5, got \(cliError.exitCode) for \(simError)"
        )
    }
    
    @Test(
        "Exit code differentiation for App Store Connect errors",
        arguments: [
            AppStoreConnectError.authenticationFailed(message: "test"),
            .uploadFailed(message: "test"),
            .invalidCredentials(message: "test"),
            .apiError(statusCode: 401, message: "test"),
        ]
    )
    func exitCodeDifferentiationAppStoreConnectErrors(ascError: AppStoreConnectError) {
        let cliError = CLIError.appStoreConnectError(ascError)
        #expect(
            cliError.exitCode == 6,
            "App Store Connect error should have exit code 6, got \(cliError.exitCode) for \(ascError)"
        )
    }
    
    @Test("Exit code differentiation for internal errors")
    func exitCodeDifferentiationInternalErrors() {
        let cliError = CLIError.internalError(message: "unexpected error")
        #expect(
            cliError.exitCode == 99,
            "Internal error should have exit code 99, got \(cliError.exitCode)"
        )
    }
    
    @Test("Exit code differentiation all error types are distinct")
    func exitCodeDifferentiationAllErrorTypesAreDistinct() {
        let exitCodes: [Int] = [
            CLIError.configurationError(.missingScheme).exitCode,
            CLIError.buildError(.buildFailed(message: "test")).exitCode,
            CLIError.testError(.testsFailed(message: "test")).exitCode,
            CLIError.archiveError(.archiveFailed(message: "test")).exitCode,
            CLIError.simulatorError(.commandFailed(message: "test")).exitCode,
            CLIError.appStoreConnectError(.authenticationFailed(message: "test")).exitCode,
            CLIError.internalError(message: "test").exitCode,
        ]
        
        let uniqueExitCodes = Set(exitCodes)
        #expect(
            uniqueExitCodes.count == exitCodes.count,
            "All error types should have distinct exit codes. Got: \(exitCodes)"
        )
        
        for exitCode in exitCodes {
            #expect(exitCode != 0, "Error exit codes should be non-zero")
        }
    }
    
    @Test("Exit code differentiation expected exit code values")
    func exitCodeDifferentiationExpectedExitCodeValues() {
        #expect(CLIError.configurationError(.missingScheme).exitCode == 1)
        #expect(CLIError.buildError(.buildFailed(message: "test")).exitCode == 2)
        #expect(CLIError.testError(.testsFailed(message: "test")).exitCode == 3)
        #expect(CLIError.archiveError(.archiveFailed(message: "test")).exitCode == 4)
        #expect(CLIError.simulatorError(.commandFailed(message: "test")).exitCode == 5)
        #expect(
            CLIError.appStoreConnectError(.authenticationFailed(message: "test")).exitCode == 6
        )
        #expect(CLIError.internalError(message: "test").exitCode == 99)
    }
    
    @Test("Exit code differentiation category names")
    func exitCodeDifferentiationCategoryNames() {
        #expect(CLIError.configurationError(.missingScheme).category == "Configuration")
        #expect(CLIError.buildError(.buildFailed(message: "test")).category == "Build")
        #expect(CLIError.testError(.testsFailed(message: "test")).category == "Test")
        #expect(CLIError.archiveError(.archiveFailed(message: "test")).category == "Archive")
        #expect(CLIError.simulatorError(.commandFailed(message: "test")).category == "Simulator")
        #expect(
            CLIError.appStoreConnectError(.authenticationFailed(message: "test")).category
            == "App Store Connect"
        )
        #expect(CLIError.internalError(message: "test").category == "Internal")
    }
}
