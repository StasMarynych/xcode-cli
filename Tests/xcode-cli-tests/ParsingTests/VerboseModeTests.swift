import Foundation
import Testing

@testable import xcode_cli

@Suite("Verbose Mode Tests")
struct VerboseModeTests {

  @Test("Verbose mode configuration error")
  func verboseModeConfigurationError() {
    let error = ConfigurationError.missingRequiredField(field: "scheme")
    let cliError = CLIError.configurationError(error)

    let normalOutput = ErrorFormatter.format(cliError, verbose: false)
    let verboseOutput = ErrorFormatter.format(cliError, verbose: true)

    // Normal output should contain basic error information
    #expect(normalOutput.contains("Error:"), "Normal output should contain 'Error:' label")
    #expect(
      normalOutput.contains("Configuration"), "Normal output should contain error category"
    )
    #expect(normalOutput.contains("Field:"), "Normal output should contain 'Field:' label")
    #expect(
      normalOutput.contains("Suggestion:"), "Normal output should contain 'Suggestion:' label"
    )

    // Verbose output should contain additional diagnostic information
    #expect(
      verboseOutput.contains("Verbose Information:"),
      "Verbose output should contain 'Verbose Information:' section"
    )
    #expect(verboseOutput.contains("Exit Code:"), "Verbose output should contain exit code")
    #expect(verboseOutput.contains("Category:"), "Verbose output should contain category")

    // Verbose output should be longer than normal output
    #expect(
      verboseOutput.count > normalOutput.count, "Verbose output should be longer than normal output"
    )
  }

  @Test("Verbose mode build error")
  func verboseModeBuildError() {
    let error = BuildError.buildFailed(message: "Build failed")
    let cliError = CLIError.buildError(error)

    let normalOutput = ErrorFormatter.format(cliError, verbose: false)
    let verboseOutput = ErrorFormatter.format(cliError, verbose: true)

    // Normal output should contain basic error information
    #expect(normalOutput.contains("Error:"), "Normal output should contain 'Error:' label")
    #expect(normalOutput.contains("Build"), "Normal output should contain error category")

    // Verbose output should contain additional diagnostic information
    #expect(
      verboseOutput.contains("Verbose Information:"),
      "Verbose output should contain 'Verbose Information:' section"
    )
    #expect(
      verboseOutput.contains("Exit Code: 2"), "Verbose output should contain correct exit code")
  }

  @Test("Verbose mode xcodebuild error")
  func verboseModeXcodebuildError() {
    let stderr = "error: Build input file cannot be found"
    let error = BuildError.xcodebuildError(exitCode: 65, stderr: stderr)
    let cliError = CLIError.buildError(error)

    let verboseOutput = ErrorFormatter.format(cliError, verbose: true)

    // Verbose output should contain xcodebuild-specific information
    #expect(
      verboseOutput.contains("xcodebuild Exit Code:"),
      "Verbose output should contain xcodebuild exit code"
    )
    #expect(verboseOutput.contains("stderr:"), "Verbose output should contain stderr label")
    #expect(verboseOutput.contains(stderr), "Verbose output should contain stderr content")
  }

  @Test("Verbose mode simctl error")
  func verboseModeSimctlError() {
    let stderr = "Unable to boot device"
    let error = SimulatorError.simctlError(exitCode: 1, stderr: stderr)
    let cliError = CLIError.simulatorError(error)

    let verboseOutput = ErrorFormatter.format(cliError, verbose: true)

    // Verbose output should contain simctl-specific information
    #expect(
      verboseOutput.contains("simctl Exit Code:"), "Verbose output should contain simctl exit code"
    )
    #expect(verboseOutput.contains("stderr:"), "Verbose output should contain stderr label")
    #expect(verboseOutput.contains(stderr), "Verbose output should contain stderr content")
  }

  @Test("Verbose mode normal mode does not include verbose info")
  func verboseModeNormalModeDoesNotIncludeVerboseInfo() {
    let error = ConfigurationError.missingRequiredField(field: "scheme")
    let cliError = CLIError.configurationError(error)

    let normalOutput = ErrorFormatter.format(cliError, verbose: false)

    // Normal output should NOT contain verbose-specific sections
    #expect(
      !normalOutput.contains("Verbose Information:"),
      "Normal output should not contain 'Verbose Information:' section"
    )
    #expect(
      !normalOutput.contains("Exit Code:"),
      "Normal output should not contain exit code in verbose format"
    )
  }

  @Test(
    "Verbose mode all error types supported",
    arguments: [
      CLIError.configurationError(.missingScheme),
      .buildError(.buildFailed(message: "test")),
      .testError(.testsFailed(message: "test")),
      .archiveError(.archiveFailed(message: "test")),
      .simulatorError(.commandFailed(message: "test")),
      .appStoreConnectError(.authenticationFailed(message: "test")),
      .internalError(message: "test"),
    ])
  func verboseModeAllErrorTypesSupported(error: CLIError) {
    let normalOutput = ErrorFormatter.format(error, verbose: false)
    let verboseOutput = ErrorFormatter.format(error, verbose: true)

    #expect(!normalOutput.isEmpty, "Normal output should not be empty for \(error)")
    #expect(!verboseOutput.isEmpty, "Verbose output should not be empty for \(error)")
    #expect(
      normalOutput.contains("Error:"), "Normal output should contain 'Error:' for \(error)"
    )
    #expect(
      verboseOutput.contains("Verbose Information:"),
      "Verbose output should contain 'Verbose Information:' for \(error)")
  }

  @Test("Verbose mode error formatter indentation")
  func verboseModeErrorFormatterIndentation() {
    let stderr = "Line 1\nLine 2\nLine 3"
    let error = BuildError.xcodebuildError(exitCode: 65, stderr: stderr)
    let cliError = CLIError.buildError(error)

    let verboseOutput = ErrorFormatter.format(cliError, verbose: true)

    // Check that stderr is properly indented
    #expect(verboseOutput.contains("    Line 1"), "Stderr should be indented")
    #expect(verboseOutput.contains("    Line 2"), "Stderr should be indented")
    #expect(verboseOutput.contains("    Line 3"), "Stderr should be indented")
  }
}
