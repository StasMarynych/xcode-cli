import Foundation

public struct ErrorFormatter {
    
    /// Formats a CLIError into a user-friendly error message
    public static func format(_ error: CLIError, verbose: Bool = false) -> String {
        var output = ""
        
        output += "Error: [\(error.category)] - \(error.underlyingError)\n"
        
        if case .configurationError(let configError) = error,
           let fieldName = configError.fieldName
        {
            output += "  Field: \(fieldName)\n"
        }
        
        if let suggestion = getSuggestion(for: error) {
            output += "  Suggestion: \(suggestion)\n"
        }
        
        if verbose {
            output += "\n"
            output += "Verbose Information:\n"
            output += "  Exit Code: \(error.exitCode)\n"
            output += "  Category: \(error.category)\n"
            
            switch error {
            case .buildError(let buildError):
                if case .xcodebuildError(let exitCode, let stderr) = buildError {
                    output += "  xcodebuild Exit Code: \(exitCode)\n"
                    output += "  stderr:\n\(indent(stderr, by: 4))\n"
                }
            case .testError(let testError):
                if case .xcodebuildError(let exitCode, let stderr) = testError {
                    output += "  xcodebuild Exit Code: \(exitCode)\n"
                    output += "  stderr:\n\(indent(stderr, by: 4))\n"
                }
            case .archiveError(let archiveError):
                if case .xcodebuildError(let exitCode, let stderr) = archiveError {
                    output += "  xcodebuild Exit Code: \(exitCode)\n"
                    output += "  stderr:\n\(indent(stderr, by: 4))\n"
                }
            case .simulatorError(let simError):
                if case .simctlError(let exitCode, let stderr) = simError {
                    output += "  simctl Exit Code: \(exitCode)\n"
                    output += "  stderr:\n\(indent(stderr, by: 4))\n"
                }
            default:
                break
            }
        }
        
        return output
    }
    
    private static func getSuggestion(for error: CLIError) -> String? {
        switch error {
        case .configurationError(let configError):
            getSuggestionForConfigurationError(configError)
        case .buildError(let buildError):
            getSuggestionForBuildError(buildError)
        case .testError(let testError):
            getSuggestionForTestError(testError)
        case .archiveError(let archiveError):
            getSuggestionForArchiveError(archiveError)
        case .simulatorError(let simError):
            getSuggestionForSimulatorError(simError)
        case .appStoreConnectError(let ascError):
            getSuggestionForAppStoreConnectError(ascError)
        case .internalError:
            "This is an unexpected error. Please report this issue with the full error message."
        }
    }
    
    private static func getSuggestionForConfigurationError(_ error: ConfigurationError) -> String? {
        switch error {
        case .fileNotFound:
            "Check that the file path is correct and the file exists"
        case .invalidYAML:
            "Verify your YAML syntax is correct. Use a YAML validator to check for errors"
        case .missingRequiredField(let field):
            "Add '\(field)' to your App Spec or use the --\(field) flag"
        case .invalidFieldType(let field, let expected):
            "Ensure '\(field)' is of type \(expected)"
        case .conflictingFields:
            "Remove one of the conflicting fields from your configuration"
        case .missingProjectOrWorkspace:
            "Add 'project_path: YourProject.xcodeproj' or 'workspace_path: YourWorkspace.xcworkspace' to your App Spec"
        case .bothProjectAndWorkspaceSpecified:
            "Remove either project_path or workspace_path from your App Spec"
        case .missingScheme:
            "Add 'scheme: YourSchemeName' to your App Spec or use --scheme flag"
        case .invalidExportMethod:
            "Use one of: app-store, ad-hoc, enterprise, development"
        case .missingSigningIdentity:
            "Add signing.identity to your App Spec or use --signing-identity flag"
        case .invalidParallelTestingWorkers:
            "parallel_testing_workers must be a positive integer"
        case .multipleProvisioningProfileFieldsSpecified:
            "Specify only one of: uuid, name, or path in provisioning_profile"
        case .invalidCodeSignStyle:
            "Use either 'automatic' or 'manual' for signing.style"
        case .mergerError:
            "Check your configuration values and ensure all required fields are present"
        }
    }
    
    private static func getSuggestionForBuildError(_ error: BuildError) -> String? {
        switch error {
        case .buildFailed:
            "Check the build output for specific compilation or linking errors"
        case .compilationError:
            "Fix the compilation error in the specified file"
        case .linkingError:
            "Ensure all required frameworks and libraries are linked correctly"
        case .signingError:
            "Verify your code signing configuration, certificates, and provisioning profiles"
        case .xcodebuildError:
            "Run with --verbose flag to see detailed xcodebuild output"
        }
    }
    
    private static func getSuggestionForTestError(_ error: TestError) -> String? {
        switch error {
        case .testsFailed:
            "Review the test output to identify which tests failed and why"
        case .testExecutionError:
            "Ensure the test target is properly configured and the simulator/device is available"
        case .testTargetNotFound:
            "Check that the test target name is correct and exists in your project"
        case .xcodebuildError:
            "Run with --verbose flag to see detailed test output"
        }
    }
    
    private static func getSuggestionForArchiveError(_ error: ArchiveError) -> String? {
        switch error {
        case .archiveFailed:
            "Ensure your project builds successfully before archiving"
        case .exportFailed:
            "Check your export options and ensure the archive is valid"
        case .invalidArchivePath:
            "Provide a valid path ending with .xcarchive"
        case .missingExportOptions:
            "Provide an export options plist or specify export_method in your App Spec"
        case .xcodebuildError:
            "Run with --verbose flag to see detailed archive/export output"
        }
    }
    
    private static func getSuggestionForSimulatorError(_ error: SimulatorError) -> String? {
        switch error {
        case .commandFailed:
            "Ensure Xcode and iOS Simulator are properly installed"
        case .bootFailed:
            "Try shutting down all simulators and booting again"
        case .shutdownFailed:
            "The simulator may already be shut down or in an invalid state"
        case .deviceNotFound:
            "Run 'xcode-cli simulator list' to see available simulators"
        case .appInstallFailed:
            "Ensure the app was built successfully and the .app bundle exists"
        case .appLaunchFailed:
            "Check that the app is installed and the bundle ID is correct"
        case .simctlError:
            "Run with --verbose flag to see detailed simctl output"
        case .installFailed:
            "Ensure the app was built successfully and the .app bundle exists"
        case .launchFailed:
            "Check that the app is installed and the bundle ID is correct"
        case .terminateFailed:
            "The app may not be running or may have already terminated"
        case .parsingFailed:
            "This may indicate an issue with the simulator or simctl output format"
        }
    }
    
    private static func getSuggestionForAppStoreConnectError(
        _ error: AppStoreConnectError
    ) -> String? {
        switch error {
        case .authenticationFailed:
            "Verify your API key ID, issuer ID, and private key are correct"
        case .uploadFailed:
            "Ensure the IPA is valid and your App Store Connect credentials are correct"
        case .invalidCredentials:
            "Check your App Store Connect API credentials"
        case .apiError:
            "Check the App Store Connect API status and your network connection"
        }
    }
    
    private static func indent(_ text: String, by spaces: Int) -> String {
        String(repeating: " ", count: spaces)
            .components(separatedBy: .newlines)
            .map { indentation + $0 }
            .joined(separator: "\n")
    }
}

// MARK: - xcodebuild Output Parser

public struct XcodeBuildOutputParser {
    
    public static func parseErrors(from output: String) -> [String] {
        var errors: [String] = []
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("error:") {
                errors.append(extractError(from: line))
            }
            
            if line.contains("ld:") && line.contains("error:") {
                errors.append(extractError(from: line))
            }
            
            if line.contains("Code Signing Error:") || line.contains("CodeSign error:") {
                errors.append(extractError(from: line))
            }
            
            if line.contains("Test Case") && line.contains("failed") {
                errors.append(extractError(from: line))
            }
        }
        
        return errors
    }
    
    private static func extractError(from line: String) -> String {
        let cleanLine = line.replacingOccurrences(
            of: "\\x1B\\[[0-9;]*[a-zA-Z]",
            with: "",
            options: .regularExpression
        )
        
        return cleanLine.trimmingCharacters(in: .whitespaces)
    }
    
    public static func parseCompilationError(from output: String) -> BuildError? {
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            if let match = line.range(
                of: #"([^:]+):(\d+):(\d+): error: (.+)"#, options: .regularExpression)
            {
                let components = line[match].components(separatedBy: ":")
                if components.count >= 4 {
                    let file = components[0]
                    let lineNumber = Int(components[1]) ?? 0
                    let message = components.dropFirst(3).joined(separator: ":")
                    return .compilationError(
                        file: file, line: lineNumber, message: message.trimmingCharacters(in: .whitespaces))
                }
            }
        }
        
        return nil
    }
    
    public static func parseLinkingError(from output: String) -> BuildError? {
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("ld:") && line.contains("error:") {
                let message = line.trimmingCharacters(in: .whitespaces)
                return .linkingError(message: message)
            }
        }
        
        return nil
    }
    
    public static func parseSigningError(from output: String) -> BuildError? {
        let lines = output.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("Code Signing Error:") || line.contains("CodeSign error:") {
                let message = line.trimmingCharacters(in: .whitespaces)
                return .signingError(message: message)
            }
        }
        
        return nil
    }
}
