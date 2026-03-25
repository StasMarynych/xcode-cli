import Foundation
import Subprocess
import System

enum FormatterError: Error, CustomStringConvertible {
    case binaryNotFound(path: String)
    case binaryNotExecutable(path: String)

    var description: String {
        switch self {
        case .binaryNotFound(let path):
            return "Formatter binary not found: \(path)"
        case .binaryNotExecutable(let path):
            return "Formatter binary is not executable: \(path)"
        }
    }
}

struct FormatterPipeline: Sendable {
    let formatterPath: String?

    init(formatterPath: String? = nil) throws {
        self.formatterPath = formatterPath
    }

    func run(xcodebuildArgs: [String]) async throws -> CommandResult {
        let exitCode: Int
        if let formatterPath {
            exitCode = try await runWithFormatter(xcodebuildArgs: xcodebuildArgs, formatterPath: formatterPath)
        } else {
            exitCode = try await runDirect(xcodebuildArgs: xcodebuildArgs)
        }
        return CommandResult(exitCode: exitCode, stdout: "", stderr: "")
    }

    // MARK: - Private

    private func extractExitCode(from status: TerminationStatus) -> Int {
        switch status {
        case .exited(let code): Int(code)
        case .unhandledException(let code): Int(code)
        }
    }

    private func runDirect(xcodebuildArgs: [String]) async throws -> Int {
        let result = try await Subprocess.run(
            .name("xcodebuild"),
            arguments: Arguments(xcodebuildArgs),
            environment: .inherit.updating(["NSUnbufferedIO": "YES"]),
            output: .standardOutput,
            error: .standardError
        )
        return extractExitCode(from: result.terminationStatus)
    }

    private func runWithFormatter(xcodebuildArgs: [String], formatterPath: String) async throws -> Int {
        let formatterExecutable: Executable

        if formatterPath.contains("/") {
            guard FileManager.default.fileExists(atPath: formatterPath) else {
                throw FormatterError.binaryNotFound(path: formatterPath)
            }
            guard FileManager.default.isExecutableFile(atPath: formatterPath) else {
                throw FormatterError.binaryNotExecutable(path: formatterPath)
            }

            formatterExecutable = .path(FilePath(formatterPath))
        } else {
            formatterExecutable = .name(formatterPath)
        }

        // Flush stderr so context table appears before formatter output
        FileHandle.standardError.synchronizeFile()

        // Pipe: xcodebuild stdout+stderr → formatter stdin (2>&1 equivalent)
        let (xcodePipeRead, xcodePipeWrite) = try FileDescriptor.pipe()

        let formatterArgs: [String]
        if formatterPath.hasSuffix("xcbeautify") || formatterPath == "xcbeautify" {
            formatterArgs = ["--disable-logging"]
        } else {
            formatterArgs = []
        }

        async let xcodebuildResult = Subprocess.run(
            .name("xcodebuild"),
            arguments: Arguments(xcodebuildArgs),
            environment: .inherit.updating(["NSUnbufferedIO": "YES"]),
            output: .fileDescriptor(xcodePipeWrite, closeAfterSpawningProcess: true),
            error: .combineWithOutput
        )

        let formatterResult = try await Subprocess.run(
            formatterExecutable,
            arguments: Arguments(formatterArgs),
            input: .fileDescriptor(xcodePipeRead, closeAfterSpawningProcess: true),
            error: .standardError
        ) { _, stdoutSequence in
            var lastPhase: String?
            
            for try await line in stdoutSequence.lines() {
                // .lines() includes the newline character — strip it along with any \r
                let trimmed = line.trimmingCharacters(in: .newlines)
                guard !trimmed.trimmingCharacters(in: .whitespaces).isEmpty else { continue }

                let phase = Self.detectPhase(in: trimmed)
                if let phase, phase != lastPhase {
                    if lastPhase != nil { 
                        FileHandle.standardOutput.write(Data("\n".utf8)) 
                    }

                    lastPhase = phase
                }

                let ts = timestampFormatter.string(from: Date())
                FileHandle.standardOutput.write(Data("[\(ts)]: ▸ \(trimmed)\n".utf8))
                FileHandle.standardOutput.synchronizeFile()
            }
        }

        let (xcode, _) = try await (xcodebuildResult, formatterResult)
        return extractExitCode(from: xcode.terminationStatus)
    }

    /// Returns a phase label when a line marks the start of a new build phase,
    /// nil if it's a continuation of the current phase.
    private static func detectPhase(in line: String) -> String? {
        for keyword in phaseKeywords where line.contains(keyword) {
            return keyword
        }
        
        if line.hasPrefix("["), let closeBracket = line.firstIndex(of: "]") {
            let afterBracket = line[line.index(after: closeBracket)...]
                .trimmingCharacters(in: .whitespaces)
            
            for action in actionKeywords where afterBracket.hasPrefix(action) {
                return action
            }
        }

        return nil
    }
}

private let phaseKeywords: [String] = [
    "Build Succeeded",
    "Build FAILED",
    "Test Succeeded",
    "Test FAILED"
]

private let actionKeywords: [String] = [
    "Compiling",
    "Linking",
    "Signing",
    "Copy",
    "Copying",
    "Processing",
    "Generate",
    "Running script",
    "Running Tests",
    "Extract App Intents"
]

private let timestampFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.dateFormat = "HH:mm:ss"
    return fmt
}()
