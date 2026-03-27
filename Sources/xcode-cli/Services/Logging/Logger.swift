// Logger.swift
// Main logging system entry point with singleton pattern

import Foundation

final class Logger: @unchecked Sendable {
    static let shared = Logger()

    /// Current verbosity level controlling which messages are logged
    private var verbosity: VerbosityLevel

    /// Whether to include timestamps in log output
    var timestampsEnabled: Bool = true

    /// Formatter for applying visual styling to messages
    private let formatter: VisualFormatter

    /// Manager for directing output to appropriate streams
    private let streamManager: StreamManager

    private let timestampFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm:ss"
        return fmt
    }()

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

    // MARK: - Section Separators

    /// Prints a visual separator — just a blank line for clean spacing
    func separator(title: String? = nil) {
        guard verbosity.shouldLog(.info) else { return }
        if let title {
            let useColors = TTYDetector().colorsEnabled()
            let styled = useColors ? ANSIColor.cyan.apply(to: title) : title
            streamManager.writeToStderr("\n\(styled)\n")
        } else {
            streamManager.writeToStderr("")
        }
    }

    // MARK: - Context Table

    /// Prints a key-value table showing command context (scheme, destination, config, etc.)
    func table(rows: [(key: String, value: String)], title: String? = nil) {
        guard verbosity.shouldLog(.info) else { return }
        streamManager.writeToStderr(formatter.formatTable(rows: rows, title: title))
    }

    // MARK: - Summary Table

    /// Prints a fastlane-style summary table with step name and elapsed time
    func summary(steps: [(name: String, duration: TimeInterval, success: Bool)]) {
        guard verbosity.shouldLog(.info) else { return }
        let colors = TTYDetector().colorsEnabled()

        let nameWidth = max(steps.map(\.name.count).max() ?? 0, 6)
        let timeWidth = 11

        let header = row(RowConfig(col1: "Step", col2: "Action", col3: "Time (in s)", nameWidth: nameWidth, timeWidth: timeWidth, colors: colors, isHeader: true))
        let divider = dividerRow(nameWidth, timeWidth, colors: colors)

        var lines: [String] = []
        lines.append(divider)
        lines.append(header)
        lines.append(divider)

        for (index, step) in steps.enumerated() {
            let timeStr = String(format: "%.0f", step.duration)
            let icon = step.success ? "✓" : "✗"
            let color: ANSIColor = step.success ? .green : .red
            let num = "\(index + 1)"
            let styledIcon = colors ? color.apply(to: icon) : icon
            let styledName = colors ? color.apply(to: step.name) : step.name
            let styledTime = colors ? ANSIColor.white.apply(to: timeStr) : timeStr
            let numPad = num.padding(toLength: 4, withPad: " ", startingAt: 0)
            let namePad = styledName.padding(toLength: nameWidth + (colors ? 9 : 0), withPad: " ", startingAt: 0)
            let timePad = styledTime.padding(toLength: timeWidth + (colors ? 9 : 0), withPad: " ", startingAt: 0)
            let sep = colors ? ANSIColor.gray.apply(to: "|") : "|"
            lines.append("\(sep) \(numPad) \(sep) \(styledIcon) \(namePad) \(sep) \(timePad) \(sep)")
        }

        lines.append(divider)
        streamManager.writeToStderr(lines.joined(separator: "\n"))
    }

    private struct RowConfig {
        let col1: String
        let col2: String
        let col3: String
        let nameWidth: Int
        let timeWidth: Int
        let colors: Bool
        let isHeader: Bool
    }

    private func row(_ config: RowConfig) -> String {
        let sep = config.colors ? ANSIColor.gray.apply(to: "|") : "|"
        let c1 = config.col1.padding(toLength: 4, withPad: " ", startingAt: 0)
        let c2 = config.col2.padding(toLength: config.nameWidth + 2, withPad: " ", startingAt: 0)
        let c3 = config.col3.padding(toLength: config.timeWidth, withPad: " ", startingAt: 0)
        let styled: (String) -> String = { str in
            config.isHeader && config.colors ? ANSIColor.cyan.apply(to: str) : str
        }
        return "\(sep) \(styled(c1)) \(sep) \(styled(c2)) \(sep) \(styled(c3)) \(sep)"
    }

    private func dividerRow(_ nameWidth: Int, _ timeWidth: Int, colors: Bool) -> String {
        let line = "+" + String(repeating: "-", count: 6) +
            "+" + String(repeating: "-", count: nameWidth + 4) +
            "+" + String(repeating: "-", count: timeWidth + 2) + "+"
        return colors ? ANSIColor.gray.apply(to: line) : line
    }

    private func currentTimestamp() -> String? {
        guard timestampsEnabled else { return nil }
        return "[\(timestampFormatter.string(from: Date()))]"
    }

    private func log(_ message: String, level: LogLevel, prefix: String?) {
        guard verbosity.shouldLog(level) else { return }
        streamManager.writeToStderr(
            formatter.format(message: message, level: level, prefix: prefix, timestamp: currentTimestamp())
        )
    }

    private func logMultiline(_ messages: [String], level: LogLevel, prefix: String?) {
        guard verbosity.shouldLog(level) else { return }
        streamManager.writeToStderr(
            formatter.format(messages: messages, level: level, prefix: prefix, timestamp: currentTimestamp())
        )
    }
}

// MARK: - Global Convenience Functions

func logInfo(_ message: String, prefix: String? = nil) { Logger.shared.info(message, prefix: prefix) }
func logSuccess(_ message: String, prefix: String? = nil) { Logger.shared.success(message, prefix: prefix) }
func logWarning(_ message: String, prefix: String? = nil) { Logger.shared.warning(message, prefix: prefix) }
func logError(_ message: String, prefix: String? = nil) { Logger.shared.error(message, prefix: prefix) }
func logDebug(_ message: String, prefix: String? = nil) { Logger.shared.debug(message, prefix: prefix) }
func logProgress(_ message: String, prefix: String? = nil) { Logger.shared.progress(message, prefix: prefix) }
func logSeparator(title: String? = nil) { Logger.shared.separator(title: title) }
func logTable(rows: [(key: String, value: String)], title: String? = nil) { Logger.shared.table(rows: rows, title: title) }
func logSummary(steps: [(name: String, duration: TimeInterval, success: Bool)]) { Logger.shared.summary(steps: steps) }
