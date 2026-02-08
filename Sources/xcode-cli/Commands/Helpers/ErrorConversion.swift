import Foundation

// MARK: - Error Conversion Helpers

/// Converts old error types to new CLIError format
extension YAMLParserError {
    func toConfigurationError() -> ConfigurationError {
        switch self {
        case .fileNotFound(let url):
            return .fileNotFound(path: url.path)
        case .invalidYAML(let message):
            return .invalidYAML(message: message)
        case .missingRequiredField(let field):
            return .missingRequiredField(field: field)
        case .invalidFieldType(let field, let expected):
            return .invalidFieldType(field: field, expected: expected)
        case .conflictingFields(let fields):
            return .conflictingFields(fields: fields)
        }
    }
}

extension ValidationError {
    func toConfigurationError() -> ConfigurationError {
        switch self {
        case .missingProjectOrWorkspace:
            return .missingProjectOrWorkspace
        case .bothProjectAndWorkspaceSpecified:
            return .bothProjectAndWorkspaceSpecified
        case .missingScheme:
            return .missingScheme
        case .invalidExportMethod(let method):
            return .invalidExportMethod(method: method)
        case .missingSigningIdentity:
            return .missingSigningIdentity
        case .invalidParallelTestingWorkers(let count):
            return .invalidParallelTestingWorkers(count: count)
        case .multipleProvisioningProfileFieldsSpecified:
            return .multipleProvisioningProfileFieldsSpecified
        }
    }
}

extension MergerError {
    func toConfigurationError() -> ConfigurationError {
        switch self {
        case .missingRequiredField(let field):
            return .missingRequiredField(field: field)
        case .invalidCodeSignStyle(let style):
            return .invalidCodeSignStyle(style: style)
        case .invalidExportMethod(let method):
            return .invalidExportMethod(method: method)
        }
    }
}

extension RunError {
    func toSimulatorError() -> SimulatorError {
        switch self {
        case .unsupportedDestination(let message):
            return .commandFailed(message: message)
        case .simulatorNotFound(let name):
            return .deviceNotFound(identifier: name)
        case .appBundleNotFound(let message):
            return .appInstallFailed(message: message)
        case .bundleIDNotFound(let message):
            return .appLaunchFailed(message: message)
        }
    }
}
