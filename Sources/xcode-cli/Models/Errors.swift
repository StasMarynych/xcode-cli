import Foundation

public enum ConfigurationError: Error, Equatable {
    case fileNotFound(path: String)
    case invalidYAML(message: String)
    case missingRequiredField(field: String)
    case invalidFieldType(field: String, expected: String)
    case conflictingFields(fields: [String])
    case missingProjectOrWorkspace
    case bothProjectAndWorkspaceSpecified
    case missingScheme
    case invalidExportMethod(method: String)
    case missingSigningIdentity
    case invalidParallelTestingWorkers(count: Int)
    case multipleProvisioningProfileFieldsSpecified
    case invalidCodeSignStyle(style: String)
    case mergerError(message: String)
    case autoDetectionFailed(String)
}

extension ConfigurationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .fileNotFound(path):
            "File not found: \(path)"
        case let .invalidYAML(message):
            "Invalid YAML: \(message)"
        case let .missingRequiredField(field):
            "Missing required field: \(field)"
        case let .invalidFieldType(field, expected):
            "Invalid field type for '\(field)': expected \(expected)"
        case let .conflictingFields(fields):
            "Conflicting fields: \(fields.joined(separator: ", "))"
        case .missingProjectOrWorkspace:
            "Missing project or workspace: specify either project_path or workspace_path"
        case .bothProjectAndWorkspaceSpecified:
            "Both project and workspace specified: use only one"
        case .missingScheme:
            "Missing required field: scheme"
        case let .invalidExportMethod(method):
            "Invalid export method: \(method)"
        case .missingSigningIdentity:
            "Missing signing identity"
        case let .invalidParallelTestingWorkers(count):
            "Invalid parallel testing workers: \(count)"
        case .multipleProvisioningProfileFieldsSpecified:
            "Multiple provisioning profile fields specified: use only one of uuid, name, or path"
        case let .invalidCodeSignStyle(style):
            "Invalid code sign style: \(style)"
        case let .mergerError(message):
            message
        case let .autoDetectionFailed(message):
            message
        }
    }
    
    public var fieldName: String? {
        switch self {
        case .missingRequiredField(let field),
                .invalidFieldType(let field, _):
            field
        case .conflictingFields(let fields):
            fields.joined(separator: ", ")
        case .missingProjectOrWorkspace:
            "project_path or workspace_path"
        case .bothProjectAndWorkspaceSpecified:
            "project_path, workspace_path"
        case .missingScheme:
            "scheme"
        case .invalidExportMethod:
            "export_method"
        case .missingSigningIdentity:
            "signing.identity"
        case .invalidParallelTestingWorkers:
            "parallel_testing_workers"
        case .multipleProvisioningProfileFieldsSpecified:
            "provisioning_profile.uuid, provisioning_profile.name, provisioning_profile.path"
        case .invalidCodeSignStyle:
            "signing.style"
        default:
            nil
        }
    }
}

public enum AutoDetectionError: Error, Equatable {
    case multipleProjectsFound([String])
    case noProjectFound
    case multipleSchemesFound([String])
    case noSchemeFound
}

public enum DestinationResolverError: Error, Equatable {
    case conflictingFlags
    case osWithoutSimulator
}

public enum BuildError: Error, Equatable {
    case buildFailed(message: String)
    case compilationError(file: String?, line: Int?, message: String)
    case linkingError(message: String)
    case signingError(message: String)
    case xcodebuildError(exitCode: Int, stderr: String)
}

extension BuildError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .buildFailed(message):
            "Build failed: \(message)"
        case let .compilationError(file, line, message):
            if let file = file, let line = line {
                "Compilation error in \(file):\(line): \(message)"
            } else if let file = file {
                "Compilation error in \(file): \(message)"
            } else {
                "Compilation error: \(message)"
            }
        case let .linkingError(message):
            "Linking error: \(message)"
        case let .signingError(message):
            "Code signing error: \(message)"
        case let .xcodebuildError(_, stderr):
            stderr
        }
    }
}

public enum TestError: Error, Equatable {
    case testsFailed(message: String)
    case testExecutionError(message: String)
    case testTargetNotFound(target: String)
    case xcodebuildError(exitCode: Int, stderr: String)
}

extension TestError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .testsFailed(message):
            "Tests failed: \(message)"
        case let .testExecutionError(message):
            "Test execution error: \(message)"
        case let .testTargetNotFound(target):
            "Test target not found: \(target)"
        case let .xcodebuildError(_, stderr):
            stderr
        }
    }
}

public enum ArchiveError: Error, Equatable {
    case archiveFailed(message: String)
    case exportFailed(message: String)
    case invalidArchivePath(path: String)
    case missingExportOptions(message: String)
    case xcodebuildError(exitCode: Int, stderr: String)
}

extension ArchiveError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .archiveFailed(let message):
            "Archive failed: \(message)"
        case .exportFailed(let message):
            "Export failed: \(message)"
        case .invalidArchivePath(let path):
            "Invalid archive path: \(path)"
        case .missingExportOptions(let message):
            "Missing export options: \(message)"
        case .xcodebuildError(_, let stderr):
            stderr
        }
    }
}

public enum SimulatorError: Error, Equatable {
    case commandFailed(message: String)
    case bootFailed(deviceID: String, reason: String)
    case shutdownFailed(deviceID: String, reason: String)
    case deviceNotFound(identifier: String)
    case appInstallFailed(message: String)
    case appLaunchFailed(message: String)
    case simctlError(exitCode: Int, stderr: String)
    case installFailed(deviceID: String, appPath: String, reason: String)
    case launchFailed(deviceID: String, bundleID: String, reason: String)
    case terminateFailed(deviceID: String, bundleID: String, reason: String)
    case parsingFailed(message: String)
}

extension SimulatorError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .commandFailed(message):
            "Simulator command failed: \(message)"
        case let .bootFailed(deviceID, reason):
            "Failed to boot simulator \(deviceID): \(reason)"
        case let .shutdownFailed(deviceID, reason):
            "Failed to shutdown simulator \(deviceID): \(reason)"
        case let .deviceNotFound(identifier):
            "Simulator device not found: \(identifier)"
        case let .appInstallFailed(message):
            "App installation failed: \(message)"
        case let .appLaunchFailed(message):
            "App launch failed: \(message)"
        case let .simctlError(exitCode, stderr):
            "simctl failed with exit code \(exitCode): \(stderr)"
        case let .installFailed(deviceID, appPath, reason):
            "Failed to install app at \(appPath) on simulator \(deviceID): \(reason)"
        case let .launchFailed(deviceID, bundleID, reason):
            "Failed to launch app \(bundleID) on simulator \(deviceID): \(reason)"
        case let .terminateFailed(deviceID, bundleID, reason):
            "Failed to terminate app \(bundleID) on simulator \(deviceID): \(reason)"
        case let .parsingFailed(message):
            "Failed to parse simulator output: \(message)"
        }
    }
}

public enum AppStoreConnectError: Error, Equatable {
    case authenticationFailed(message: String)
    case uploadFailed(message: String)
    case invalidCredentials(message: String)
    case apiError(statusCode: Int, message: String)
}

extension AppStoreConnectError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .authenticationFailed(message):
            "App Store Connect authentication failed: \(message)"
        case let .uploadFailed(message):
            "Upload failed: \(message)"
        case let .invalidCredentials(message):
            "Invalid credentials: \(message)"
        case let .apiError(statusCode, message):
            "App Store Connect API error (\(statusCode)): \(message)"
        }
    }
}

public enum CLIError: Error {
    case configurationError(ConfigurationError)
    case buildError(BuildError)
    case testError(TestError)
    case archiveError(ArchiveError)
    case simulatorError(SimulatorError)
    case appStoreConnectError(AppStoreConnectError)
    case internalError(message: String)
}

public extension CLIError {
    var exitCode: Int {
        switch self {
        case .configurationError:
            return 1
        case .buildError(let buildError):
            if case .xcodebuildError(let exitCode, _) = buildError {
                return exitCode
            }
            return 2
        case .testError(let testError):
            if case .xcodebuildError(let exitCode, _) = testError {
                return exitCode
            }
            return 3
        case .archiveError(let archiveError):
            if case .xcodebuildError(let exitCode, _) = archiveError {
                return exitCode
            }
            return 4
        case .simulatorError:
            return 5
        case .appStoreConnectError:
            return 6
        case .internalError:
            return 99
        }
    }
    
    var category: String {
        switch self {
        case .configurationError:
            "Configuration"
        case .buildError:
            "Build"
        case .testError:
            "Test"
        case .archiveError:
            "Archive"
        case .simulatorError:
            "Simulator"
        case .appStoreConnectError:
            "App Store Connect"
        case .internalError:
            "Internal"
        }
    }
    
    var underlyingError: Error {
        switch self {
        case .configurationError(let error):
            error
        case .buildError(let error):
            error
        case .testError(let error):
            error
        case .archiveError(let error):
            error
        case .simulatorError(let error):
            error
        case .appStoreConnectError(let error):
            error
        case .internalError(let message):
            NSError(
                domain: "XcodeCLI",
                code: 99,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
        }
    }
}

extension CLIError: CustomStringConvertible {
    public var description: String {
        "\(underlyingError)"
    }
}

extension CLIError: LocalizedError {
    public var errorDescription: String? {
        ErrorFormatter.format(self, verbose: false)
    }
}

extension CLIError: CustomNSError {
    public static var errorDomain: String {
        "com.xcode-cli.error"
    }
    
    public var errorCode: Int {
        exitCode
    }
    
    public var errorUserInfo: [String: Any] {
        [
            NSLocalizedDescriptionKey: ErrorFormatter.format(self, verbose: false)
        ]
    }
}
