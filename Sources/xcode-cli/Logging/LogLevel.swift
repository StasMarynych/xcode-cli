// LogLevel.swift
// Defines log levels with associated icons and colors

enum LogLevel {
    case info
    case success
    case warning
    case error
    case debug
    case progress

    var icon: String {
        switch self {
        case .info: "ℹ"
        case .success: "✓"
        case .warning: "⚠"
        case .error: "✗"
        case .debug: "◆"
        case .progress: "▸"
        }
    }

    var color: ANSIColor {
        switch self {
        case .info: .cyan
        case .success: .green
        case .warning: .yellow
        case .error: .red
        case .debug: .gray
        case .progress: .blue
        }
    }
}
