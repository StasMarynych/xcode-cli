// VerbosityLevel.swift
// Defines verbosity levels and filtering logic

enum VerbosityLevel: String {
    case quiet  // Only errors and raw output
    case normal  // Info, success, warning, error, progress
    case verbose  // All levels including debug
    
    func shouldLog(_ level: LogLevel) -> Bool {
        switch self {
        case .quiet:
            level == .error
        case .normal:
            level != .debug
        case .verbose:
            true
        }
    }
}
