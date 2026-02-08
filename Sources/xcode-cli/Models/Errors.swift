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
}

extension ConfigurationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fileNotFound(let path):
            "File not found: \(path)"
        case .invalidYAML(let message):
            "Invalid YAML: \(message)"
        case .missingRequiredField(let field):
            "Missing required field: \(field)"
        case .invalidFieldType(let field, let expected):
            "Invalid field type for '\(field)': expected \(expected)"
        case .conflictingFields(let fields):
            "Conflicting fields: \(fields.joined(separator: ", "))"
        case .missingProjectOrWorkspace:
            "Missing project or workspace: specify either project_path or workspace_path"
        case .bothProjectAndWorkspaceSpecified:
            "Both project and workspace specified: use only one"
        case .missingScheme:
            "Missing required field: scheme"
        case .invalidExportMethod(let method):
            "Invalid export method: \(method)"
        case .missingSigningIdentity:
            "Missing signing identity"
        case .invalidParallelTestingWorkers(let count):
            "Invalid parallel testing workers: \(count)"
        case .multipleProvisioningProfileFieldsSpecified:
            "Multiple provisioning profile fields specified: use only one of uuid, name, or path"
        case .invalidCodeSignStyle(let style):
            "Invalid code sign style: \(style)"
        case .mergerError(let message):
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
        case .buildFailed(let message):
            "Build failed: \(message)"
        case .compilationError(let file, let line, let message):
            if let file = file, let line = line {
                "Compilation error in \(file):\(line): \(message)"
            } else if let file = file {
                "Compilation error in \(file): \(message)"
            } else {
                "Compilation error: \(message)"
            }
        case .linkingError(let message):
            "Linking error: \(message)"
        case .signingError(let message):
            "Code signing error: \(message)"
        case .xcodebuildError(let exitCode, let stderr):
            "xcodebuild failed with exit code \(exitCode): \(stderr)"
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
        case .testsFailed(let message):
            "Tests failed: \(message)"
        case .testExecutionError(let message):
            "Test execution error: \(message)"
        case .testTargetNotFound(let target):
            "Test target not found: \(target)"
        case .xcodebuildError(let exitCode, let stderr):
            "xcodebuild test failed with exit code \(exitCode): \(stderr)"
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
        case .xcodebuildError(let exitCode, let stderr):
            "xcodebuild archive/export failed with exit code \(exitCode): \(stderr)"
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
        case .commandFailed(let message):
            "Simulator command failed: \(message)"
        case .bootFailed(let deviceID, let reason):
            "Failed to boot simulator \(deviceID): \(reason)"
        case .shutdownFailed(let deviceID, let reason):
            "Failed to shutdown simulator \(deviceID): \(reason)"
        case .deviceNotFound(let identifier):
            "Simulator device not found: \(identifier)"
        case .appInstallFailed(let message):
            "App installation failed: \(message)"
        case .appLaunchFailed(let message):
            "App launch failed: \(message)"
        case .simctlError(let exitCode, let stderr):
            "simctl failed with exit code \(exitCode): \(stderr)"
        case .installFailed(let deviceID, let appPath, let reason):
            "Failed to install app at \(appPath) on simulator \(deviceID): \(reason)"
        case .launchFailed(let deviceID, let bundleID, let reason):
            "Failed to launch app \(bundleID) on simulator \(deviceID): \(reason)"
        case .terminateFailed(let deviceID, let bundleID, let reason):
            "Failed to terminate app \(bundleID) on simulator \(deviceID): \(reason)"
        case .parsingFailed(let message):
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
        case .authenticationFailed(let message):
            "App Store Connect authentication failed: \(message)"
        case .uploadFailed(let message):
            "Upload failed: \(message)"
        case .invalidCredentials(let message):
            "Invalid credentials: \(message)"
        case .apiError(let statusCode, let message):
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

extension CLIError {
    public var exitCode: Int {
        switch self {
        case .configurationError:
            1
        case .buildError:
            2
        case .testError:
            3
        case .archiveError:
            4
        case .simulatorError:
            5
        case .appStoreConnectError:
            6
        case .internalError:
            99
        }
    }
    
    public var category: String {
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
    
    public var underlyingError: Error {
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
