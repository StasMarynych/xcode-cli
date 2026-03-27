# xcode-cli

A native Swift CLI tool for Xcode build automation. Provides a Ruby-free alternative to Fastlane for iOS build, test, and release workflows.

## Features

- **Zero Ruby Dependencies**: Pure Swift implementation
- **YAML Configuration**: Version-controllable project settings
- **CLI Override Flexibility**: Command-line flags override YAML for CI customization
- **Comprehensive Commands**: Build, test, run, archive, export, and simulator management

## Requirements

- macOS 26.0+
- Swift 6.2+

## Installation

```bash
swift build -c release
cp .build/release/xcode-cli /usr/local/bin/
```

## Quick Start

### Zero-config (auto-detection)

Run from your project directory — xcode-cli will find the project and scheme automatically:

```bash
xcode-cli build
xcode-cli test
```

Auto-detection works when there is exactly one `.xcodeproj` or `.xcworkspace` in the current directory and exactly one scheme. If multiple are found, the CLI exits with a descriptive error listing the candidates.

### Using an App Spec file

Create an `app-spec.yaml` file:

```yaml
scheme: "MyApp"
build_configuration: "Release"
```

Then pass it to any command:

```bash
xcode-cli build --spec app-spec.yaml
```

## Commands

### build

Build an Xcode project or workspace.

```bash
xcode-cli build [OPTIONS]
```

**Options:**
- `--spec <path>` — Path to App Spec YAML file
- `-s, --scheme <name>` — Scheme name
- `-c, --configuration <name>` — Build configuration (Debug/Release)
- `--simulator <name>` — Target simulator by name (e.g. `iPhone 15`)
- `--device <name>` — Target physical device by name
- `--os <version>` — OS version for simulator (e.g. `17.0`); requires `--simulator`
- `--derived-data-path <path>` — Custom derived data path
- `--signing-identity <identity>` — Code signing identity
- `--signing-style <style>` — Code signing style (`automatic` or `manual`)
- `--team-id <id>` — Development team ID
- `--provisioning-profile-uuid <uuid>` — Provisioning profile UUID
- `--formatter <path>` — Path to formatter binary (e.g. `xcbeautify`, `xcpretty`)
- `--verbose` — Enable verbose output
- `--quiet` — Suppress non-essential output

**Examples:**

```bash
# Auto-detect project and scheme
xcode-cli build

# Build using App Spec
xcode-cli build --spec app-spec.yaml

# Build for a specific simulator
xcode-cli build --spec app-spec.yaml --simulator "iPhone 15 Pro"

# Build with a specific OS version
xcode-cli build --spec app-spec.yaml --simulator "iPhone 15" --os 17.0

# Build for a physical device
xcode-cli build --spec app-spec.yaml --device "My iPhone"

# Pipe output through xcbeautify
xcode-cli build --spec app-spec.yaml --formatter xcbeautify
```

### test

Run unit and UI tests.

```bash
xcode-cli test [OPTIONS]
```

**Options:** All `build` options, plus:
- `--test-targets <targets>` — Specific test targets to run (repeatable)
- `--parallel` — Enable parallel testing
- `--parallel-testing-workers <n>` — Number of parallel testing workers

**Examples:**

```bash
# Run all tests
xcode-cli test --spec app-spec.yaml

# Run specific test targets
xcode-cli test --spec app-spec.yaml --test-targets MyAppTests --test-targets MyAppUITests

# Run tests in parallel on a specific simulator
xcode-cli test --spec app-spec.yaml --simulator "iPhone 15" --parallel
```

### build-for-testing

Compile the app and test bundles without running tests. Produces a `.xctestrun` file for use with `test-without-building`.

```bash
xcode-cli build-for-testing [OPTIONS]
```

**Options:** Same as `build`.

**Examples:**

```bash
# Build for testing (CI build stage)
xcode-cli build-for-testing --spec app-spec.yaml --simulator "iPhone 15"
```

### test-without-building

Run previously compiled test bundles without rebuilding. Consumes the `.xctestrun` file produced by `build-for-testing`.

```bash
xcode-cli test-without-building [OPTIONS]
```

**Options:** Same as `test`.

**Examples:**

```bash
# Run tests without rebuilding (CI test stage)
xcode-cli test-without-building --spec app-spec.yaml --simulator "iPhone 15"

# Run specific targets without rebuilding
xcode-cli test-without-building --spec app-spec.yaml --test-targets MyAppTests
```

### run

Build and run the app on a simulator.

```bash
xcode-cli run [OPTIONS]
```

**Options:** All `build` options, plus:
- `--wait-for-debugger` — Wait for debugger to attach before launching

**Examples:**

```bash
# Build and run on a simulator
xcode-cli run --spec app-spec.yaml --simulator "iPhone 15"

# Run with debugger wait
xcode-cli run --spec app-spec.yaml --simulator "iPhone 15" --wait-for-debugger
```

### archive

Create an archive (`.xcarchive`) for distribution.

```bash
xcode-cli archive [OPTIONS]
```

**Options:**
- `--spec <path>` — Path to App Spec YAML file
- `-s, --scheme <name>` — Scheme name
- `-c, --configuration <name>` — Build configuration
- `--archive-path <path>` — Archive output path
- `--derived-data-path <path>` — Custom derived data path
- `--signing-identity <identity>` — Code signing identity
- `--signing-style <style>` — Code signing style
- `--team-id <id>` — Development team ID
- `--provisioning-profile-uuid <uuid>` — Provisioning profile UUID
- `--formatter <path>` — Path to formatter binary
- `--verbose` / `--quiet`

**Examples:**

```bash
# Archive using App Spec
xcode-cli archive --spec app-spec.yaml

# Archive with custom output path
xcode-cli archive --spec app-spec.yaml --archive-path ./build/MyApp.xcarchive
```

### export

Export an IPA from an existing archive.

```bash
xcode-cli export <archive-path> [OPTIONS]
```

**Arguments:**
- `<archive-path>` — Path to `.xcarchive` file

**Options:**
- `--spec <path>` — Path to App Spec YAML file
- `--export-path <path>` — Export output directory
- `--export-method <method>` — Export method (`app-store`, `ad-hoc`, `enterprise`, `development`)
- `--export-options-plist <path>` — Path to `exportOptions.plist`
- `--verbose` / `--quiet`

**Examples:**

```bash
# Export for App Store
xcode-cli export ./build/MyApp.xcarchive --export-method app-store --export-path ./build

# Export with custom options plist
xcode-cli export ./build/MyApp.xcarchive --export-options-plist ./ExportOptions.plist
```

### release

Archive and export in a single step. Defaults to `app-store` export method when not specified in the spec.

```bash
xcode-cli release [OPTIONS]
```

**Options:**
- `--spec <path>` — Path to App Spec YAML file
- `-s, --scheme <name>` — Scheme name
- `-c, --configuration <name>` — Build configuration
- `--derived-data-path <path>` — Custom derived data path
- `--signing-identity <identity>` — Code signing identity
- `--signing-style <style>` — Code signing style
- `--team-id <id>` — Development team ID
- `--provisioning-profile-uuid <uuid>` — Provisioning profile UUID
- `--formatter <path>` — Path to formatter binary
- `--verbose` / `--quiet`

**Examples:**

```bash
# Archive and export in one step
xcode-cli release --spec app-spec.yaml

# Release with explicit signing overrides
xcode-cli release --spec app-spec.yaml --signing-style manual --team-id TEAM123
```

### simulator

Manage iOS Simulators.

#### simulator list

```bash
xcode-cli simulator list
```

#### simulator boot

```bash
xcode-cli simulator boot <device>
```

**Arguments:**
- `<device>` — Device name or UDID

**Examples:**

```bash
xcode-cli simulator boot "iPhone 15"
xcode-cli simulator boot 12345678-1234-1234-1234-123456789012
```

#### simulator shutdown

```bash
xcode-cli simulator shutdown <device>
```

### validate

Validate an App Spec YAML file.

```bash
xcode-cli validate <spec-path>
```

**Examples:**

```bash
xcode-cli validate app-spec.yaml
```

## App Spec YAML Schema

The App Spec file is the primary configuration interface. CLI flags are overrides for common runtime variations.

### Minimal Configuration

All fields are optional — xcode-cli will auto-detect the project and scheme when they are absent:

```yaml
scheme: "MyApp"
```

Or even just:

```yaml
build_configuration: "Release"
```

### Complete Schema

```yaml
# Project source (choose one; omit both to enable auto-detection)
project_path: "MyApp.xcodeproj"
# workspace_path: "MyApp.xcworkspace"

# Scheme (omit to enable auto-detection)
scheme: "MyApp"

# Build configuration (defaults to "Release")
build_configuration: "Release"

# Signing configuration
signing:
  style: "manual"           # "manual" or "automatic"
  identity: "Apple Distribution: My Company (TEAM123)"
  team_id: "TEAM123"
  provisioning_profile:
    uuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    # name: "MyApp Distribution Profile"
    # path: "/path/to/profile.mobileprovision"

# Test configuration
test_targets:
  - "MyAppTests"
  - "MyAppUITests"
parallel_testing: true
parallel_testing_workers: 4

# Archive and export
archive_path: "./build/MyApp.xcarchive"
export_path: "./build"
export_method: "app-store"   # app-store, ad-hoc, enterprise, development
export_options_plist: "./ExportOptions.plist"

# Build output
build_output_path: "./DerivedData"
```

### Field Reference

| Field | Type | Description |
|---|---|---|
| `project_path` | string | Path to `.xcodeproj` file |
| `workspace_path` | string | Path to `.xcworkspace` file |
| `scheme` | string | Xcode scheme name |
| `build_configuration` | string | Build configuration (default: `Release`) |
| `signing.style` | string | `manual` or `automatic` |
| `signing.identity` | string | Code signing identity (certificate name) |
| `signing.team_id` | string | Development team ID |
| `signing.provisioning_profile.uuid` | string | Provisioning profile UUID |
| `signing.provisioning_profile.name` | string | Provisioning profile name |
| `signing.provisioning_profile.path` | string | Path to `.mobileprovision` file |
| `test_targets` | array | Test target names to run |
| `parallel_testing` | boolean | Enable parallel test execution |
| `parallel_testing_workers` | integer | Number of parallel test workers |
| `archive_path` | string | Output path for `.xcarchive` |
| `export_path` | string | Output directory for exported IPA |
| `export_method` | string | `app-store`, `ad-hoc`, `enterprise`, or `development` |
| `export_options_plist` | string | Path to custom `exportOptions.plist` |
| `build_output_path` | string | Custom derived data path |

## Configuration Precedence

Values are resolved in this order (highest to lowest priority):

1. CLI flags
2. App Spec YAML values
3. Auto-detected values (project, workspace, scheme)
4. Default values

**Example:**

```yaml
# app-spec.yaml
scheme: "MyApp"
build_configuration: "Release"
```

```bash
# Override configuration for a debug build
xcode-cli build --spec app-spec.yaml --configuration Debug
```

## Auto-Detection

When `project_path`, `workspace_path`, and `scheme` are absent from both the spec and CLI flags, xcode-cli scans the current working directory:

- If exactly one `.xcworkspace` is found, it is used (workspaces take precedence over projects)
- If no workspace is found and exactly one `.xcodeproj` is found, it is used
- If multiple files are found, the CLI exits with an error listing the candidates
- If no files are found, the CLI exits with an error

Scheme auto-detection runs `xcodebuild -list` on the resolved project/workspace:

- If exactly one scheme is found, it is used automatically
- If multiple schemes are found, the CLI exits with an error listing them and asking you to specify one via `--scheme` or the spec file

## Destination Flags

Instead of raw xcodebuild destination strings, use the friendly shorthands:

| Flag | Resolves to |
|---|---|
| `--simulator "iPhone 15"` | `platform=iOS Simulator,name=iPhone 15,OS=latest` |
| `--simulator "iPhone 15" --os 17.0` | `platform=iOS Simulator,name=iPhone 15,OS=17.0` |
| `--device "My iPhone"` | `platform=iOS,name=My iPhone` |
| _(neither)_ | `generic/platform=iOS Simulator` |

`--simulator` and `--device` are mutually exclusive. `--os` requires `--simulator`.

## Output Formatter

Pipe xcodebuild output through an external formatter binary:

```bash
# Using xcbeautify
xcode-cli build --spec app-spec.yaml --formatter xcbeautify

# Using xcpretty
xcode-cli test --spec app-spec.yaml --formatter xcpretty

# Using a full path
xcode-cli build --spec app-spec.yaml --formatter /usr/local/bin/xcbeautify
```

The formatter binary is validated before xcodebuild starts — if it doesn't exist or isn't executable, the CLI exits with an error without running the build. The xcodebuild exit code always takes precedence over the formatter's exit code.

## Verbosity

All commands support `--verbose` and `--quiet`:

| Mode | Output |
|---|---|
| default | info, success, warning, error messages |
| `--verbose` | all messages including debug |
| `--quiet` | errors only |

Custom log messages are written to stderr; raw xcodebuild output goes to stdout. This means you can redirect them independently:

```bash
# Capture only xcodebuild output
xcode-cli build --spec app-spec.yaml > build.log

# Suppress xcodebuild output, keep CLI messages
xcode-cli build --spec app-spec.yaml 2>/dev/null
```

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Success |
| `1` | Configuration error (invalid YAML, missing required fields) |
| `2` | Build failure |
| `3` | Test failure |
| `4` | Archive/Export failure |
| `5` | Simulator error |
| `6` | App Store Connect error |
| `99` | Internal error |

## Examples

### CI/CD Pipeline

```bash
#!/bin/bash
set -e

# Validate configuration
xcode-cli validate app-spec.yaml

# Run tests in parallel
xcode-cli test --spec app-spec.yaml --parallel

# Archive and export in one step
xcode-cli release --spec app-spec.yaml
```

### Split Build/Test Pipeline

```bash
# Stage 1: build
xcode-cli build-for-testing --spec app-spec.yaml --simulator "iPhone 15"

# Stage 2: test (reuses build artifacts)
xcode-cli test-without-building --spec app-spec.yaml --simulator "iPhone 15"
```

### Local Development

```bash
# Boot simulator
xcode-cli simulator boot "iPhone 15"

# Build and run (auto-detects project and scheme)
xcode-cli run --simulator "iPhone 15"

# Run tests
xcode-cli test --simulator "iPhone 15"
```

### Multiple Environments

```yaml
# app-spec.yaml
scheme: "MyApp"
signing:
  style: "manual"
  team_id: "TEAM123"
```

```bash
# Debug build
xcode-cli build --spec app-spec.yaml --configuration Debug

# Release build with formatter
xcode-cli build --spec app-spec.yaml --configuration Release --formatter xcbeautify
```

## License

See [LICENSE](./LICENSE) file for details.
