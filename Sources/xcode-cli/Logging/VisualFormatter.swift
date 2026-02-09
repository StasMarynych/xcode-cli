// VisualFormatter.swift
// Handles visual styling of log messages including colors, icons, and formatting

import Foundation

/// Formats log messages with appropriate styling based on log level and terminal capabilities
struct VisualFormatter {
    private let ttyDetector: TTYDetector
    
    init() {
        self.ttyDetector = TTYDetector()
    }
    
    /// Format a single-line message with appropriate styling
    /// - Parameters:
    ///   - message: The message to format
    ///   - level: The log level determining icon and color
    ///   - prefix: Optional prefix to prepend to the message
    /// - Returns: Formatted message string ready for output
    func format(
        message: String,
        level: LogLevel,
        prefix: String? = nil
    ) -> String {
        let useColors = shouldUseColors()
        let icon = level.icon
        let color = level.color
        
        var formatted = ""
        
        if useColors {
            formatted += color.apply(to: icon)
        } else {
            formatted += icon
        }
        
        formatted += " "
        
        if let prefix = prefix {
            if useColors {
                formatted += color.apply(to: "[\(prefix)]")
            } else {
                formatted += "[\(prefix)]"
            }
            formatted += " "
        }
        
        if useColors {
            formatted += color.apply(to: message)
        } else {
            formatted += message
        }
        
        return formatted
    }
    
    /// Format multiple lines with proper indentation
    /// - Parameters:
    ///   - messages: Array of message lines to format
    ///   - level: The log level determining icon and color
    ///   - prefix: Optional prefix to prepend to the first line
    /// - Returns: Formatted multi-line message string ready for output
    func format(
        messages: [String],
        level: LogLevel,
        prefix: String? = nil
    ) -> String {
        guard !messages.isEmpty else {
            return ""
        }
        
        let useColors = shouldUseColors()
        let icon = level.icon
        let color = level.color
        
        var result = ""
        
        // Format the first line with icon and prefix
        var firstLine = ""
        if useColors {
            firstLine += color.apply(to: icon)
        } else {
            firstLine += icon
        }
        firstLine += " "
        
        if let prefix = prefix {
            if useColors {
                firstLine += color.apply(to: "[\(prefix)]")
            } else {
                firstLine += "[\(prefix)]"
            }
            firstLine += " "
        }
        
        if useColors {
            firstLine += color.apply(to: messages[0])
        } else {
            firstLine += messages[0]
        }
        
        result += firstLine
        
        // Format continuation lines with proper indentation
        // Indent by 2 spaces to align with content after icon
        let indent = "  "
        for message in messages.dropFirst() {
            result += "\n" + indent
            if useColors {
                result += color.apply(to: message)
            } else {
                result += message
            }
        }
        
        return result
    }
    
    private func shouldUseColors() -> Bool {
        ttyDetector.colorsEnabled()
    }
}
