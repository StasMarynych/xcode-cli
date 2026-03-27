// VerbosityLevel.swift
// Defines verbosity levels and filtering logic

enum VerbosityLevel: String {
    case quiet
    case normal
    case verbose

    func shouldLog(_ level: LogLevel) -> Bool {
        switch self {
        case .quiet: level == .error
        case .normal: level != .debug
        case .verbose: true
        }
    }
}
