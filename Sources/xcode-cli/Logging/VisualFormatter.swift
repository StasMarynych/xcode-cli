// VisualFormatter.swift
// Handles visual styling of log messages including colors, icons, and formatting

import Foundation

/// Formats log messages with appropriate styling based on log level and terminal capabilities
struct VisualFormatter {
    private let ttyDetector = TTYDetector()

    func format(message: String, level: LogLevel, prefix: String? = nil, timestamp: String? = nil) -> String {
        let useColors = ttyDetector.colorsEnabled()
        var result = ""

        if let ts = timestamp {
            result += styled(ts, color: .gray, enabled: useColors) + " "
        }

        result += styled(level.icon, color: level.color, enabled: useColors) + " "

        if let prefix {
            result += styled("[\(prefix)]", color: level.color, enabled: useColors) + " "
        }

        return result + styled(message, color: level.color, enabled: useColors)
    }

    func format(messages: [String], level: LogLevel, prefix: String? = nil, timestamp: String? = nil) -> String {
        guard !messages.isEmpty else { return "" }

        let useColors = ttyDetector.colorsEnabled()
        var result = ""

        if let ts = timestamp {
            result += styled(ts, color: .gray, enabled: useColors) + " "
        }

        result += styled(level.icon, color: level.color, enabled: useColors) + " "

        if let prefix {
            result += styled("[\(prefix)]", color: level.color, enabled: useColors) + " "
        }

        result += styled(messages[0], color: level.color, enabled: useColors)

        for message in messages.dropFirst() {
            result += "\n  " + styled(message, color: level.color, enabled: useColors)
        }

        return result
    }

    /// Formats a key-value context table (like fastlane's parameter table)
    func formatTable(rows: [(key: String, value: String)], title: String? = nil) -> String {
        let useColors = ttyDetector.colorsEnabled()
        guard !rows.isEmpty else { return "" }

        let keyWidth = rows.map(\.key.count).max() ?? 0
        var lines: [String] = []

        if let title {
            lines.append(useColors ? ANSIColor.cyan.apply(to: title) : title)
        }

        for row in rows {
            // Pad using plain key length (no ANSI in key), then colorize the whole line
            let paddedKey = row.key.padding(toLength: keyWidth, withPad: " ", startingAt: 0)
            let line = "  \(paddedKey)  \(row.value)"
            lines.append(useColors ? ANSIColor.gray.apply(to: "  \(paddedKey)  ") + ANSIColor.white.apply(to: row.value) : line)
        }

        return lines.joined(separator: "\n")
    }

    private func styled(_ text: String, color: ANSIColor, enabled: Bool) -> String {
        enabled ? color.apply(to: text) : text
    }
}
