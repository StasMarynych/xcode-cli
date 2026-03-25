import Foundation

func resolveConfig(spec specPath: String?, flags: CommandFlags) throws -> Configuration {
    let appSpec = try loadAppSpec(from: specPath)

    do {
        return try ConfigurationMerger().merge(spec: appSpec, flags: flags)
    } catch let error as MergerError {
        throw CLIError.configurationError(error.toConfigurationError())
    } catch {
        throw CLIError.configurationError(.mergerError(message: error.localizedDescription))
    }
}

func applyVerbosity(quiet: Bool, verbose: Bool) {
    if quiet { 
        Logger.shared.setVerbosity(.quiet) 
    } else if verbose { 
        Logger.shared.setVerbosity(.verbose) 
    }
}

private func loadAppSpec(from path: String?) throws -> AppSpec? {
    guard let path else { return nil }

    do {
        let spec = try YAMLParser().parse(fileURL: URL(fileURLWithPath: path))
        try ConfigurationValidator().validate(spec)
        
        return spec
    } catch let error as YAMLParserError {
        throw CLIError.configurationError(error.toConfigurationError())
    } catch let error as ValidationError {
        throw CLIError.configurationError(error.toConfigurationError())
    } catch {
        throw CLIError.configurationError(.mergerError(message: error.localizedDescription))
    }
}
