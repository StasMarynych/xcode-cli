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

    func info(_ message: String, prefix: String? = nil) {
        log(message, level: .info, prefix: prefix)
    }

    func success(_ message: String, prefix: String? = nil) {
        log(message, level: .success, prefix: prefix)
    }

    func warning(_ message: String, prefix: String? = nil) {
        log(message, level: .warning, prefix: prefix)
    }

    func error(_ message: String, prefix: String? = nil) {
        log(message, level: .error, prefix: prefix)
    }

    func debug(_ message: String, prefix: String? = nil) {
        log(message, level: .debug, prefix: prefix)
    }

    func progress(_ message: String, prefix: String? = nil) {
        log(message, level: .progress, prefix: prefix)
    }

    // MARK: - Multi-line Logging Methods

    func info(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .info, prefix: prefix)
    }

    func success(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .success, prefix: prefix)
    }

    func warning(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .warning, prefix: prefix)
    }

    func error(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .error, prefix: prefix)
    }

    func debug(_ messages: [String], prefix: String? = nil) {
        logMultiline(messages, level: .debug, prefix: prefix)
    }

    // MARK: - Private Helpers

    private func log(_ message: String, level: LogLevel, prefix: String?) {
        guard verbosity.shouldLog(level) else { return }
        streamManager.writeToStderr(formatter.format(message: message, level: level, prefix: prefix))
    }

    private func logMultiline(_ messages: [String], level: LogLevel, prefix: String?) {
        guard verbosity.shouldLog(level) else { return }
        streamManager.writeToStderr(formatter.format(messages: messages, level: level, prefix: prefix))
    }
}

// MARK: - Global Convenience Functions

func logInfo(_ message: String, prefix: String? = nil) { Logger.shared.info(message, prefix: prefix) }
func logSuccess(_ message: String, prefix: String? = nil) { Logger.shared.success(message, prefix: prefix) }
func logWarning(_ message: String, prefix: String? = nil) { Logger.shared.warning(message, prefix: prefix) }
func logError(_ message: String, prefix: String? = nil) { Logger.shared.error(message, prefix: prefix) }
func logDebug(_ message: String, prefix: String? = nil) { Logger.shared.debug(message, prefix: prefix) }
func logProgress(_ message: String, prefix: String? = nil) { Logger.shared.progress(message, prefix: prefix) }
