import Foundation

func resolveConfig(
    spec specPath: String?,
    flags: CommandFlags,
    directory: String = FileManager.default.currentDirectoryPath
) async throws -> Configuration {
    let appSpec = try loadAppSpec(from: specPath)
    var enrichedFlags = flags

    if enrichedFlags.project == nil, enrichedFlags.workspace == nil, appSpec?.projectPath == nil, appSpec?.workspacePath == nil {
        do {
            let reference = try AutoDetector().detectProjectOrWorkspace(in: directory)

            switch reference {
            case .workspace(let path):
                enrichedFlags.workspace = path
            case .project(let path):
                enrichedFlags.project = path
            }
        } catch let error as AutoDetectionError {
            throw CLIError.configurationError(.autoDetectionFailed(
                autoDetectionMessage(for: error, directory: directory, reference: nil)
            ))
        }
    }

    if enrichedFlags.scheme == nil, appSpec?.scheme == nil {
        let reference: ProjectReference?
        if let workspace = enrichedFlags.workspace {
            reference = .workspace(path: workspace)
        } else if let project = enrichedFlags.project {
            reference = .project(path: project)
        } else {
            reference = nil
        }

        if let reference {
            do {
                enrichedFlags.scheme = try await AutoDetector().detectScheme(for: reference)
            } catch let error as AutoDetectionError {
                throw CLIError.configurationError(.autoDetectionFailed(
                    autoDetectionMessage(for: error, directory: directory, reference: reference)
                ))
            }
        }
    }

    do {
        return try ConfigurationMerger().merge(spec: appSpec, flags: enrichedFlags)
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

private func autoDetectionMessage(
    for error: AutoDetectionError,
    directory: String,
    reference: ProjectReference?
) -> String {
    switch error {
    case .noProjectFound:
        return "No .xcodeproj or .xcworkspace found in \(directory). Create a spec file or run from your project directory."
    case .multipleProjectsFound(let paths):
        return "Multiple projects found: \(paths.joined(separator: ", ")). Specify one via the spec file."
    case .noSchemeFound:
        let project = reference?.path ?? directory
        return "No schemes found in \(project). Ensure the project has at least one scheme."
    case .multipleSchemesFound(let schemes):
        return "Multiple schemes found: \(schemes.joined(separator: ", ")). Use --scheme or set scheme in the spec file."
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
