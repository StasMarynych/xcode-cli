import Foundation

/// Detects terminal capabilities for proper color and formatting output
struct TTYDetector {
    /// Check if stderr is connected to a TTY (terminal)
    /// - Returns: true if stderr is a TTY, false otherwise
    func isStderrTTY() -> Bool {
        isatty(STDERR_FILENO) != 0
    }
    
    /// Determine if ANSI colors should be enabled
    /// Checks both TTY status and environment variables
    /// - Returns: true if colors should be enabled, false otherwise
    func colorsEnabled() -> Bool {
        guard isStderrTTY() else { return false }

        if ProcessInfo.processInfo.environment["NO_COLOR"] != nil { return false }

        if let term = ProcessInfo.processInfo.environment["TERM"], term.lowercased() == "dumb" {
            return false
        }

        if let forceColor = ProcessInfo.processInfo.environment["FORCE_COLOR"],
           !forceColor.isEmpty && forceColor != "0" {
            return true
        }

        return true
    }
}
