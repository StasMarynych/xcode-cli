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

/// Logs a fastlane-style context table showing the resolved build configuration
func logCommandContext(_ config: Configuration, command: String) {
    logSeparator(title: command)

    var rows: [(key: String, value: String)] = [
        ("Scheme", config.scheme),
        ("Configuration", config.buildConfiguration)
    ]

    if let project = config.projectPath {
        rows.append(("Project", project))
    } else if let workspace = config.workspacePath {
        rows.append(("Workspace", workspace))
    }

    switch config.destination {
    case let .simulator(name, os):
        rows.append(("Destination", "iOS Simulator · \(name) · \(os)"))
    case let .device(name):
        rows.append(("Destination", "Device · \(name)"))
    case let .generic(platform):
        rows.append(("Destination", "Generic · \(platform)"))
    }

    if let signing = config.signing {
        if let style = signing.style {
            rows.append(("Signing", style.rawValue))
        }
        if let team = signing.teamID {
            rows.append(("Team", team))
        }
    }

    logTable(rows: rows, title: nil)
    logSeparator()
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
