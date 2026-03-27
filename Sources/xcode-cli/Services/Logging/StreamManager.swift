import Foundation

/// Manages output to the correct streams (stdout/stderr)
struct StreamManager {
    /// Write a message to stderr
    /// - Parameter message: The message to write
    func writeToStderr(_ message: String) {
        let messageWithNewline = ensureNewline(message)
        
        if let data = messageWithNewline.data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }
    
    /// Ensure the message ends with a newline
    /// - Parameter message: The message to check
    /// - Returns: The message with a newline appended if needed
    private func ensureNewline(_ message: String) -> String {
        if message.hasSuffix("\n") {
            message
        } else {
            message + "\n"
        }
    }
}
