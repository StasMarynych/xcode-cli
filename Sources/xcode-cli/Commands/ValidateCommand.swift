import ArgumentParser
import Foundation

struct ValidateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate an App Spec YAML file"
    )
    
    @Argument(help: "Path to App Spec YAML file")
    var spec: String
    
    func run() async throws {
        let url = URL(fileURLWithPath: spec)
        let parser = YAMLParser()
        let validator = ConfigurationValidator()
        
        do {
            print("Validating App Spec: \(spec)")
            print("")
            
            let appSpec = try parser.parse(fileURL: url)
            try validator.validate(appSpec)
            
            print("✓ App Spec is valid")
            print("")
            print("Configuration Summary:")
            print("---------------------")
            
            if let projectPath = appSpec.projectPath {
                print("Project: \(projectPath)")
            }
            
            if let workspacePath = appSpec.workspacePath {
                print("Workspace: \(workspacePath)")
            }
            
            print("Scheme: \(appSpec.scheme)")
            
            if let buildConfiguration = appSpec.buildConfiguration {
                print("Build Configuration: \(buildConfiguration)")
            }
            
            if let signing = appSpec.signing {
                print("")
                print("Signing Configuration:")
                
                if let style = signing.style {
                    print("  Style: \(style.rawValue)")
                }
                
                if let identity = signing.identity {
                    print("  Identity: \(identity)")
                }
                
                if let teamID = signing.teamID {
                    print("  Team ID: \(teamID)")
                }
                
                if let profile = signing.provisioningProfile {
                    if let uuid = profile.uuid {
                        print("  Provisioning Profile UUID: \(uuid)")
                    } else if let name = profile.name {
                        print("  Provisioning Profile Name: \(name)")
                    } else if let path = profile.path {
                        print("  Provisioning Profile Path: \(path)")
                    }
                }
            }
            
            if let testTargets = appSpec.testTargets, !testTargets.isEmpty {
                print("")
                print("Test Targets:")
                for target in testTargets {
                    print("  - \(target)")
                }
            }
            
            if let parallelTesting = appSpec.parallelTesting, parallelTesting {
                print("")
                print("Parallel Testing: Enabled")
                
                if let workers = appSpec.parallelTestingWorkers {
                    print("  Workers: \(workers)")
                }
            }
            
            if let archivePath = appSpec.archivePath {
                print("")
                print("Archive Path: \(archivePath)")
            }
            
            if let exportPath = appSpec.exportPath {
                print("Export Path: \(exportPath)")
            }
            
            if let exportMethod = appSpec.exportMethod {
                print("Export Method: \(exportMethod.rawValue)")
            }
            
            if let exportOptionsPlist = appSpec.exportOptionsPlist {
                print("Export Options Plist: \(exportOptionsPlist)")
            }
            
            if let buildOutputPath = appSpec.buildOutputPath {
                print("")
                print("Build Output Path: \(buildOutputPath)")
            }
            
        } catch let error as YAMLParserError {
            print("✗ Validation failed")
            print("")
            throw CLIError.configurationError(
                error.toConfigurationError()
            )
        } catch let error as ValidationError {
            print("✗ Validation failed")
            print("")
            throw CLIError.configurationError(
                error.toConfigurationError()
            )
        } catch {
            print("✗ Validation failed")
            print("")
            throw CLIError.configurationError(
                ConfigurationError.mergerError(message: error.localizedDescription)
            )
        }
    }
}
