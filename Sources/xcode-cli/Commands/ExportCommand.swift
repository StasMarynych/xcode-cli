import ArgumentParser
import Foundation

struct ExportCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export an IPA from an archive"
    )
    
    @Argument(help: "Path to xcarchive")
    var archivePath: String
    
    @Option(name: .long, help: "Path to App Spec YAML file")
    var spec: String?
    
    @Option(name: .long, help: "Export output path")
    var exportPath: String?
    
    @Option(name: .long, help: "Export method (app-store, ad-hoc, enterprise, development)")
    var exportMethod: String?
    
    @Option(name: .long, help: "Path to exportOptions.plist")
    var exportOptionsPlist: String?
    
    @Flag(name: .long, help: "Enable verbose output")
    var verbose: Bool = false
    
    @Flag(name: .long, help: "Suppress non-essential output")
    var quiet: Bool = false
    
    func run() async throws {
        applyVerbosity(quiet: quiet, verbose: verbose)

        let appSpec = try loadAppSpec(from: spec)
        let merger = ConfigurationMerger()
        
        // For export, minimal configuration is required,
        // So dummy configuration with required fields should be used
        let dummyFlags = CommandFlags(
            spec: spec,
            scheme: "DummyScheme",  // Required but not used for export
            destination: .generic(platform: "iOS"),  // Required but not used for export
            exportPath: exportPath,
            exportMethod: exportMethod,
            exportOptionsPlist: exportOptionsPlist
        )
        
        let config: Configuration
        
        do {
            config = try merger.merge(spec: appSpec, flags: dummyFlags)
        } catch let error as MergerError {
            throw CLIError.configurationError(error.toConfigurationError())
        } catch {
            throw CLIError.configurationError(.mergerError(message: error.localizedDescription))
        }
        
        let executor = CommandExecutor(processRunner: ProcessRunner())
        let start = Date()

        let result = try await executor.executeExport(
            archivePath: archivePath,
            config: config
        )
        let duration = Date().timeIntervalSince(start)

        logSeparator()
        logSummary(steps: [("export", duration, result.isSuccess)])

        if !result.isSuccess {
            throw CLIError.archiveError(.xcodebuildError(
                exitCode: result.exitCode,
                stderr: result.stderr
            ))
        }
    }
    
    private func loadAppSpec(from path: String?) throws -> AppSpec? {
        guard let specPath = path else {
            return nil
        }
        
        let url = URL(fileURLWithPath: specPath)
        let parser = YAMLParser()
        
        do {
            let spec = try parser.parse(fileURL: url)
            let validator = ConfigurationValidator()
            try validator.validate(spec)
            
            return spec
        } catch let error as YAMLParserError {
            throw CLIError.configurationError(error.toConfigurationError())
        } catch let error as ValidationError {
            throw CLIError.configurationError(error.toConfigurationError())
        } catch {
            throw CLIError.configurationError(.mergerError(message: error.localizedDescription))
        }
    }
}
