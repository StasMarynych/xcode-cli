// Logger.swift
// Main logging system entry point with singleton pattern

import Foundation

final class Logger: @unchecked Sendable {
    static let shared = Logger()
    
    /// Current verbosity level controlling which messages are logged
    private var verbosity: VerbosityLevel
    
    /// Formatter for applying visual styling to messages
    private let formatter: VisualFormatter
    
    /// Manager for directing output to appropriate streams
    private let streamManager: StreamManager
    
    private init() {
        self.verbosity = .normal
        self.formatter = VisualFormatter()
        self.streamManager = StreamManager()
    }
    
    /// Set the verbosity level for filtering log messages
    /// - Parameter level: The verbosity level to apply
    func setVerbosity(_ level: VerbosityLevel) {
        self.verbosity = level
    }
    
    // MARK: - Core Logging Methods
    
    /// Log an informational message
    /// - Parameters:
    ///   - message: The message to log
    ///   - prefix: Optional prefix for contextual grouping
    func info(_ message: String, prefix: String? = nil) {
        log(message, level: .info, prefix: prefix)
    }
    
    /// Log a success message
    /// - Parameters:
    ///   - message: The message to log
    ///   - prefix: Optional prefix for contextual grouping
    func success(_ message: String, prefix: String? = nil) {
        log(message, level: .success, prefix: prefix)
    }
    
    /// Log a warning message
    /// - Parameters:
    ///   - message: The message to log
    ///   - prefix: Optional prefix for contextual grouping
    func warning(_ message: String, prefix: String? = nil) {
        log(message, level: .warning, prefix: prefix)
    }
    
    /// Log an error message
    /// - Parameters:
    ///   - message: The message to log
    ///   - prefix: Optional prefix for contextual grouping
    func error(_ message: String, prefix: String? = nil) {
        log(message, level: .error, prefix: prefix)
    }
    
    /// Log a debug message
    /// - Parameters:
    ///   - message: The message to log
    ///   - prefix: Optional prefix for contextual grouping
    func debug(_ message: String, prefix: String? = nil) {
        log(message, level: .debug, prefix: prefix)
    }
    
    /// Log a progress message
    /// - Parameters:
    ///   - message: The message to log
    ///   - prefix: Optional prefix for contextual grouping
    func progress(_ message: String, prefix: String? = nil) {
        log(message, level: .progress, prefix: prefix)
    }
    
    // MARK: - Multi-line Logging Methods
    
    /// Log multiple informational messages with proper indentation
    /// - Parameters:
    ///   - messages: Array of message lines to log
    ///   - prefix: Optional prefix for contextual grouping
    func info(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .info, prefix: prefix)
    }
    
    /// Log multiple success messages with proper indentation
    /// - Parameters:
    ///   - messages: Array of message lines to log
    ///   - prefix: Optional prefix for contextual grouping
    func success(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .success, prefix: prefix)
    }
    
    /// Log multiple warning messages with proper indentation
    /// - Parameters:
    ///   - messages: Array of message lines to log
    ///   - prefix: Optional prefix for contextual grouping
    func warning(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .warning, prefix: prefix)
    }
    
    /// Log multiple error messages with proper indentation
    /// - Parameters:
    ///   - messages: Array of message lines to log
    ///   - prefix: Optional prefix for contextual grouping
    func error(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .error, prefix: prefix)
    }
    
    /// Log multiple debug messages with proper indentation
    /// - Parameters:
    ///   - messages: Array of message lines to log
    ///   - prefix: Optional prefix for contextual grouping
    func debug(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .debug, prefix: prefix)
    }
    
    // MARK: - Private Helpers
    
    /// Internal logging method that handles verbosity filtering, formatting, and output
    /// - Parameters:
    ///   - message: The message to log
    ///   - level: The log level
    ///   - prefix: Optional prefix for contextual grouping
    private func log(_ message: String, level: LogLevel, prefix: String?) {
        // Check if this message should be logged based on verbosity level
        guard verbosity.shouldLog(level) else {
            return
        }
        
        let formattedMessage = formatter.format(
            message: message,
            level: level,
            prefix: prefix
        )
        
        streamManager.writeToStderr(formattedMessage)
    }
    
    /// Internal multi-line logging method that handles verbosity filtering, formatting, and output
    /// - Parameters:
    ///   - messages: Array of message lines to log
    ///   - level: The log level
    ///   - prefix: Optional prefix for contextual grouping
    private func logMultiline(_ messages: [String], level: LogLevel, prefix: String?) {
        guard verbosity.shouldLog(level) else {
            return
        }
        
        let formattedMessage = formatter.format(
            messages: messages,
            level: level,
            prefix: prefix
        )
        
        streamManager.writeToStderr(formattedMessage)
    }
}
