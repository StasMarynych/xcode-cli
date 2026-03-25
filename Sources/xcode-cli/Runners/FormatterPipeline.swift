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

    func run(xcodebuildArgs: [String]) async throws -> Int {
        if let formatterPath {
            return try await runWithFormatter(xcodebuildArgs: xcodebuildArgs, formatterPath: formatterPath)
        }

        return try await runDirect(xcodebuildArgs: xcodebuildArgs)
    }

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
        let (pipeReadEnd, pipeWriteEnd) = try FileDescriptor.pipe()

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

        async let xcodebuildResult = Subprocess.run(
            .name("xcodebuild"),
            arguments: Arguments(xcodebuildArgs),
            environment: .inherit.updating(["NSUnbufferedIO": "YES"]),
            output: .fileDescriptor(pipeWriteEnd, closeAfterSpawningProcess: true),
            error: .standardError
        )

        async let formatterResult = Subprocess.run(
            formatterExecutable,
            input: .fileDescriptor(pipeReadEnd, closeAfterSpawningProcess: true),
            output: .standardOutput,
            error: .standardError
        )

        let (xcode, _) = try await (xcodebuildResult, formatterResult)
        return extractExitCode(from: xcode.terminationStatus)
    }
}
