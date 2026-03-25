import Foundation

/// Helper for handling and formatting CLI errors
struct ErrorHandler {
    static func handle(_ error: CLIError, verbose: Bool) -> Never {
        let formattedError = ErrorFormatter.format(error, verbose: verbose)
        
        fputs(formattedError, stderr)
        fputs("\n", stderr)
        exit(Int32(error.exitCode))
    }
    
    static func execute(verbose: Bool, _ block: () async throws -> Void) async {
        do {
            try await block()
        } catch let error as CLIError {
            handle(error, verbose: verbose)
        } catch {
            let cliError = CLIError.internalError(message: error.localizedDescription)
            handle(cliError, verbose: verbose)
        }
    }
}
