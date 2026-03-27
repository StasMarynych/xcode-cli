import Foundation

enum MergerError: Error, Equatable {
    case missingRequiredField(String)
    case invalidCodeSignStyle(String)
    case invalidExportMethod(String)
    case autoDetectionFailed(String)
}

struct ConfigurationMerger {
    func merge(spec: AppSpec?, flags: CommandFlags) throws -> Configuration {
        let projectPath = flags.project ?? spec?.projectPath
        let workspacePath = flags.workspace ?? spec?.workspacePath
        
        guard let scheme = flags.scheme ?? spec?.scheme else {
            throw MergerError.missingRequiredField("scheme")
        }
        
        guard projectPath != nil || workspacePath != nil else {
            throw MergerError.missingRequiredField("project_path or workspace_path")
        }
        
        let buildConfiguration = flags.configuration ?? spec?.buildConfiguration ?? "Release"
        let destination = flags.destination ?? .generic(platform: "iOS Simulator")
        let signing = try mergeSigningConfiguration(spec: spec, flags: flags)
        let testTargets = flags.testTargets ?? spec?.testTargets ?? []
        let archivePath = flags.archivePath ?? spec?.archivePath
        let exportPath = flags.exportPath ?? spec?.exportPath
        let exportMethod = try parseExportMethod(flags.exportMethod ?? spec?.exportMethod?.rawValue)
        let exportOptionsPlist = flags.exportOptionsPlist ?? spec?.exportOptionsPlist
        let buildOutputPath = flags.derivedDataPath ?? spec?.buildOutputPath
        let parallelTesting = flags.parallelTesting ?? spec?.parallelTesting ?? false
        let parallelTestingWorkers = flags.parallelTestingWorkers ?? spec?.parallelTestingWorkers
        
        return Configuration(
            projectPath: projectPath,
            workspacePath: workspacePath,
            scheme: scheme,
            buildConfiguration: buildConfiguration,
            destination: destination,
            signing: signing,
            testTargets: testTargets,
            archivePath: archivePath,
            exportPath: exportPath,
            exportMethod: exportMethod,
            exportOptionsPlist: exportOptionsPlist,
            buildOutputPath: buildOutputPath,
            parallelTesting: parallelTesting,
            parallelTestingWorkers: parallelTestingWorkers
        )
    }
    
    private func mergeSigningConfiguration(
        spec: AppSpec?,
        flags: CommandFlags
    ) throws -> SigningConfiguration? {
        let hasSpecSigning = spec?.signing != nil
        let hasFlagSigning = flags.signingIdentity != nil ||
        flags.signingStyle != nil ||
        flags.provisioningProfilePath != nil ||
        flags.teamID != nil
        
        if !hasSpecSigning && !hasFlagSigning {
            return nil
        }
        
        let style = try parseCodeSignStyle(flags.signingStyle ?? spec?.signing?.style?.rawValue)
        let identity = flags.signingIdentity ?? spec?.signing?.identity
        let teamID = flags.teamID ?? spec?.signing?.teamID
        let provisioningProfile = try mergeProvisioningProfile(spec: spec, flags: flags)
        
        return SigningConfiguration(
            style: style,
            identity: identity,
            teamID: teamID,
            provisioningProfile: provisioningProfile
        )
    }
    
    private func mergeProvisioningProfile(
        spec: AppSpec?,
        flags: CommandFlags
    ) throws -> ProvisioningProfile? {
        if let path = flags.provisioningProfilePath {
            return ProvisioningProfile(path: path)
        }
        return spec?.signing?.provisioningProfile
    }
    
    private func parseCodeSignStyle(_ styleString: String?) throws -> CodeSignStyle? {
        guard let styleStr = styleString else {
            return nil
        }
        
        guard let style = CodeSignStyle(rawValue: styleStr) else {
            throw MergerError.invalidCodeSignStyle(styleStr)
        }
        
        return style
    }
    
    private func parseExportMethod(_ methodString: String?) throws -> ExportMethod? {
        guard let methodStr = methodString else {
            return nil
        }
        
        guard let method = ExportMethod(rawValue: methodStr) else {
            throw MergerError.invalidExportMethod(methodStr)
        }
        
        return method
    }
}
