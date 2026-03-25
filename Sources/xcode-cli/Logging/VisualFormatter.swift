// VisualFormatter.swift
// Handles visual styling of log messages including colors, icons, and formatting

import Foundation

/// Formats log messages with appropriate styling based on log level and terminal capabilities
struct VisualFormatter {
    private let ttyDetector = TTYDetector()

    func format(message: String, level: LogLevel, prefix: String? = nil) -> String {
        let useColors = ttyDetector.colorsEnabled()
        var result = styled(level.icon, color: level.color, enabled: useColors) + " "

        if let prefix {
            result += styled("[\(prefix)]", color: level.color, enabled: useColors) + " "
        }

        return result + styled(message, color: level.color, enabled: useColors)
    }

    func format(messages: [String], level: LogLevel, prefix: String? = nil) -> String {
        guard !messages.isEmpty else { return "" }

        let useColors = ttyDetector.colorsEnabled()
        var result = styled(level.icon, color: level.color, enabled: useColors) + " "

        if let prefix {
            result += styled("[\(prefix)]", color: level.color, enabled: useColors) + " "
        }

        result += styled(messages[0], color: level.color, enabled: useColors)

        for message in messages.dropFirst() {
            result += "\n  " + styled(message, color: level.color, enabled: useColors)
        }

        return result
    }

    private func styled(_ text: String, color: ANSIColor, enabled: Bool) -> String {
        enabled ? color.apply(to: text) : text
    }
}
