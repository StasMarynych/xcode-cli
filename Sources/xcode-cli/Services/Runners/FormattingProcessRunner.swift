import Foundation
import Subprocess
import System

enum FormatterError: Error, CustomStringConvertible {
    case binaryNotFound(path: String)
    case binaryNotExecutable(path: String)

    var description: String {
        switch self {
        case .binaryNotFound(let path):
            "Formatter binary not found: \(path)"
        case .binaryNotExecutable(let path):
            "Formatter binary is not executable: \(path)"
        }
    }
}

struct FormattingProcessRunner: ProcessRunnerProtocol, Sendable {
    let formatterPath: String

    func run(
        executable: String,
        arguments: [String],
        environment: [Environment.Key: String?],
        streamOutput: Bool
    ) async throws -> CommandResult {
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

        FileHandle.standardError.synchronizeFile()

        let (xcodePipeRead, xcodePipeWrite) = try FileDescriptor.pipe()

        let formatterArgs: [String]
        if formatterPath.hasSuffix("xcbeautify") || formatterPath == "xcbeautify" {
            formatterArgs = ["--disable-logging"]
        } else {
            formatterArgs = []
        }

        let mergedEnvironment = Environment.inherit.updating(environment)

        async let processResult = Subprocess.run(
            .name(executable),
            arguments: Arguments(arguments),
            environment: mergedEnvironment,
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

        let (result, _) = try await (processResult, formatterResult)
        let exitCode = extractExitCode(from: result.terminationStatus)
        return CommandResult(exitCode: exitCode, stdout: "", stderr: "")
    }

    private func extractExitCode(from status: TerminationStatus) -> Int {
        switch status {
        case .exited(let code): Int(code)
        case .unhandledException(let code): Int(code)
        }
    }

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
