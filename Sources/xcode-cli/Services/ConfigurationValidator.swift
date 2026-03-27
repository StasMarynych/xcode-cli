import Foundation

public struct ConfigurationValidator {
    public init() {}
    
    public func validate(_ spec: AppSpec) throws {
        try validateProjectOrWorkspace(spec)
        try validateSigningConfiguration(spec)
        try validateExportConfiguration(spec)
    }
    
    private func validateProjectOrWorkspace(_ spec: AppSpec) throws {
        let hasProject = spec.projectPath != nil
        let hasWorkspace = spec.workspacePath != nil

        if hasProject && hasWorkspace {
            throw ValidationError.bothProjectAndWorkspaceSpecified
        }
    }
    
    private func validateSigningConfiguration(_ spec: AppSpec) throws {
        guard
            let signing = spec.signing,
            let profile = signing.provisioningProfile
        else {
            return
        }
        
        let specifiedCount = [profile.uuid, profile.name, profile.path].compactMap { $0 }.count
        
        if specifiedCount > 1 {
            throw ValidationError.multipleProvisioningProfileFieldsSpecified
        }
    }
    
    private func validateExportConfiguration(_ spec: AppSpec) throws {
        guard let exportMethod = spec.exportMethod else {
            return
        }
        
        let validMethods: [ExportMethod] = [.appStore, .adHoc, .enterprise, .development]
        if !validMethods.contains(exportMethod) {
            throw ValidationError.invalidExportMethod(exportMethod.rawValue)
        }
    }
}

public enum ValidationError: Error, Equatable {
    case missingProjectOrWorkspace
    case bothProjectAndWorkspaceSpecified
    case missingScheme
    case invalidExportMethod(String)
    case missingSigningIdentity
    case invalidParallelTestingWorkers(Int)
    case multipleProvisioningProfileFieldsSpecified
}
