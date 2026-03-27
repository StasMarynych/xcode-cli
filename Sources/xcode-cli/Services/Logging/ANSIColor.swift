// ANSIColor.swift
// Defines ANSI color codes for terminal output

enum ANSIColor: String {
    case reset = "\u{001B}[0m"
    case red = "\u{001B}[31m"
    case green = "\u{001B}[32m"
    case yellow = "\u{001B}[33m"
    case blue = "\u{001B}[34m"
    case magenta = "\u{001B}[35m"
    case cyan = "\u{001B}[36m"
    case gray = "\u{001B}[90m"
    case white = "\u{001B}[97m"
    case bold = "\u{001B}[1m"

    func apply(to text: String) -> String {
        self.rawValue + text + ANSIColor.reset.rawValue
    }
}
