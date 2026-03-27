import Foundation

// MARK: - Error Conversion Helpers

/// Converts old error types to new CLIError format
extension YAMLParserError {
    func toConfigurationError() -> ConfigurationError {
        switch self {
        case let .fileNotFound(url):
            .fileNotFound(path: url.path)
        case let .invalidYAML(message):
            .invalidYAML(message: message)
        case let .missingRequiredField(field):
            .missingRequiredField(field: field)
        case let .invalidFieldType(field, expected):
            .invalidFieldType(field: field, expected: expected)
        case let .conflictingFields(fields):
            .conflictingFields(fields: fields)
        }
    }
}

extension ValidationError {
    func toConfigurationError() -> ConfigurationError {
        switch self {
        case .missingProjectOrWorkspace:
            .missingProjectOrWorkspace
        case .bothProjectAndWorkspaceSpecified:
            .bothProjectAndWorkspaceSpecified
        case .missingScheme:
            .missingScheme
        case .invalidExportMethod(let method):
            .invalidExportMethod(method: method)
        case .missingSigningIdentity:
            .missingSigningIdentity
        case .invalidParallelTestingWorkers(let count):
            .invalidParallelTestingWorkers(count: count)
        case .multipleProvisioningProfileFieldsSpecified:
            .multipleProvisioningProfileFieldsSpecified
        }
    }
}

extension MergerError {
    func toConfigurationError() -> ConfigurationError {
        switch self {
        case .missingRequiredField(let field):
            .missingRequiredField(field: field)
        case .invalidCodeSignStyle(let style):
            .invalidCodeSignStyle(style: style)
        case .invalidExportMethod(let method):
            .invalidExportMethod(method: method)
        case .autoDetectionFailed(let message):
            .autoDetectionFailed(message)
        }
    }
}

extension RunError {
    func toSimulatorError() -> SimulatorError {
        switch self {
        case .unsupportedDestination(let message):
            .commandFailed(message: message)
        case .simulatorNotFound(let name):
            .deviceNotFound(identifier: name)
        case .appBundleNotFound(let message):
            .appInstallFailed(message: message)
        case .bundleIDNotFound(let message):
            .appLaunchFailed(message: message)
        }
    }
}
