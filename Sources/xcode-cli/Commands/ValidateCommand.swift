import ArgumentParser
import Foundation

struct ValidateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate an App Spec YAML file"
    )
    
    @Argument(help: "Path to App Spec YAML file")
    var spec: String
    
    @Flag(name: .long, help: "Enable verbose output")
    var verbose: Bool = false
    
    @Flag(name: .long, help: "Suppress non-essential output")
    var quiet: Bool = false
    
    func run() async throws {
        applyVerbosity(quiet: quiet, verbose: verbose)

        let url = URL(fileURLWithPath: spec)
        let parser = YAMLParser()
        let validator = ConfigurationValidator()

        do {
            logProgress("Validating App Spec: \(spec)")

            let appSpec = try parser.parse(fileURL: url)
            try validator.validate(appSpec)

            logSuccess("App Spec is valid")

            var rows: [(key: String, value: String)] = []

            if let projectPath = appSpec.projectPath {
                rows.append(("Project", projectPath))
            }
            if let workspacePath = appSpec.workspacePath {
                rows.append(("Workspace", workspacePath))
            }

            if let scheme = appSpec.scheme { rows.append(("Scheme", scheme)) }

            if let buildConfiguration = appSpec.buildConfiguration {
                rows.append(("Configuration", buildConfiguration))
            }

            if let signing = appSpec.signing {
                if let style = signing.style { rows.append(("Signing Style", style.rawValue)) }
                if let identity = signing.identity { rows.append(("Signing Identity", identity)) }
                if let teamID = signing.teamID { rows.append(("Team ID", teamID)) }
                if let profile = signing.provisioningProfile {
                    if let uuid = profile.uuid {
                        rows.append(("Profile UUID", uuid))
                    } else if let name = profile.name {
                        rows.append(("Profile Name", name))
                    } else if let path = profile.path {
                        rows.append(("Profile Path", path))
                    }
                }
            }
            if let testTargets = appSpec.testTargets, !testTargets.isEmpty {
                rows.append(("Test Targets", testTargets.joined(separator: ", ")))
            }

            if let parallelTesting = appSpec.parallelTesting, parallelTesting {
                let workers = appSpec.parallelTestingWorkers.map { " (\($0) workers)" } ?? ""
                rows.append(("Parallel Testing", "Enabled\(workers)"))
            }

            if let archivePath = appSpec.archivePath { rows.append(("Archive Path", archivePath)) }
            if let exportPath = appSpec.exportPath { rows.append(("Export Path", exportPath)) }
            if let exportMethod = appSpec.exportMethod { rows.append(("Export Method", exportMethod.rawValue)) }
            if let exportOptionsPlist = appSpec.exportOptionsPlist { rows.append(("Export Options Plist", exportOptionsPlist)) }
            if let buildOutputPath = appSpec.buildOutputPath { rows.append(("Build Output Path", buildOutputPath)) }

            logTable(rows: rows, title: "Configuration Summary")
        } catch let error as YAMLParserError {
            logError("Validation failed")
            throw CLIError.configurationError(error.toConfigurationError())
        } catch let error as ValidationError {
            logError("Validation failed")
            throw CLIError.configurationError(error.toConfigurationError())
        } catch {
            logError("Validation failed")
            throw CLIError.configurationError(.mergerError(message: error.localizedDescription))
        }
    }
}
