# xcode-cli

A native Swift CLI tool for Xcode build automation. Provides a Ruby-free alternative to Fastlane for iOS build, test, and release workflows.

## Features

- **Zero Ruby Dependencies**: Pure Swift implementation
- **YAML Configuration**: Version-controllable project settings
- **CLI Override Flexibility**: Command-line flags override YAML for CI customization
- **Comprehensive Commands**: Build, test, run, archive, export, and simulator management
- **Property-Based Testing**: Extensive test coverage with correctness properties

## Installation

### Build from Source

```bash
swift build -c release
cp .build/release/xcode-cli /usr/local/bin/
```

## Quick Start

### Using App Spec File

Create an `app-spec.yaml` file:

```yaml
project_path: "MyApp.xcodeproj"
scheme: "MyApp"
build_configuration: "Release"
```

Build your project:

```bash
xcode-cli build --spec app-spec.yaml
```

### Using CLI Flags Only

```bash
xcode-cli build --project MyApp.xcodeproj --scheme MyApp --configuration Release
```

## Commands

### build

Build an Xcode project or workspace.

```bash
xcode-cli build [OPTIONS]
```

**Options:**
- `--spec <path>` - Path to App Spec YAML file
- `--project <path>` - Project file path (.xcodeproj)
- `--workspace <path>` - Workspace file path (.xcworkspace)
- `-s, --scheme <name>` - Scheme name
- `-c, --configuration <name>` - Build configuration (Debug/Release)
- `-d, --destination <dest>` - Destination (e.g., "platform=iOS Simulator,name=iPhone 15")
- `--verbose` - Enable verbose output

**Examples:**

```bash
# Build using App Spec
xcode-cli build --spec app-spec.yaml

# Build with CLI flags
xcode-cli build --project MyApp.xcodeproj --scheme MyApp --configuration Release

# Build for specific destination
xcode-cli build --spec app-spec.yaml --destination "platform=iOS Simulator,name=iPhone 15"
```

### test

Run unit and UI tests.

```bash
xcode-cli test [OPTIONS]
```

**Options:**
- All build options (--spec, --project, --scheme, etc.)
- `--test-targets <targets>` - Specific test targets to run
- `--parallel` - Enable parallel testing
- `--verbose` - Enable verbose output

**Examples:**

```bash
# Run all tests
xcode-cli test --spec app-spec.yaml

# Run specific test targets
xcode-cli test --spec app-spec.yaml --test-targets MyAppTests MyAppUITests

# Run tests in parallel
xcode-cli test --spec app-spec.yaml --parallel
```

### run

Build and run the app on a simulator or device.

```bash
xcode-cli run [OPTIONS]
```

**Options:**
- All build options (--spec, --project, --scheme, etc.)
- `--wait-for-debugger` - Wait for debugger to attach before launching
- `--verbose` - Enable verbose output

**Examples:**

```bash
# Build and run on default simulator
xcode-cli run --spec app-spec.yaml

# Run with debugger wait
xcode-cli run --spec app-spec.yaml --wait-for-debugger

# Run on specific simulator
xcode-cli run --project MyApp.xcodeproj --scheme MyApp --destination "platform=iOS Simulator,name=iPhone 15 Pro"
```

### archive

Create an archive (.xcarchive) for distribution.

```bash
xcode-cli archive [OPTIONS]
```

**Options:**
- All build options (--spec, --project, --scheme, etc.)
- `--archive-path <path>` - Archive output path
- `--verbose` - Enable verbose output

**Examples:**

```bash
# Create archive using App Spec
xcode-cli archive --spec app-spec.yaml

# Create archive with custom path
xcode-cli archive --spec app-spec.yaml --archive-path ./build/MyApp.xcarchive
```

### export

Export an IPA from an archive.

```bash
xcode-cli export <archive-path> [OPTIONS]
```

**Arguments:**
- `<archive-path>` - Path to .xcarchive file

**Options:**
- `--export-path <path>` - Export output directory
- `--export-method <method>` - Export method (app-store, ad-hoc, enterprise, development)
- `--export-options-plist <path>` - Path to exportOptions.plist
- `--verbose` - Enable verbose output

**Examples:**

```bash
# Export for App Store
xcode-cli export ./build/MyApp.xcarchive --export-method app-store --export-path ./build

# Export with custom options plist
xcode-cli export ./build/MyApp.xcarchive --export-options-plist ./ExportOptions.plist
```

### simulator

Manage iOS Simulators.

#### simulator list

List available simulators.

```bash
xcode-cli simulator list
```

#### simulator boot

Boot a simulator.

```bash
xcode-cli simulator boot <device>
```

**Arguments:**
- `<device>` - Device name or UDID

**Examples:**

```bash
xcode-cli simulator boot "iPhone 15"
xcode-cli simulator boot 12345678-1234-1234-1234-123456789012
```

#### simulator shutdown

Shutdown a simulator.

```bash
xcode-cli simulator shutdown <device>
```

**Arguments:**
- `<device>` - Device name or UDID

**Examples:**

```bash
xcode-cli simulator shutdown "iPhone 15"
```

### validate

Validate an App Spec YAML file.

```bash
xcode-cli validate <spec-path>
```

**Arguments:**
- `<spec-path>` - Path to App Spec YAML file

**Examples:**

```bash
xcode-cli validate app-spec.yaml
```

## App Spec YAML Schema

The App Spec file defines project configuration in YAML format.

### Minimal Configuration

```yaml
# Project source (choose one)
project_path: "MyApp.xcodeproj"

# Required: Scheme name
scheme: "MyApp"
```

### Complete Schema

```yaml
# Project Source (specify exactly ONE)
project_path: "MyApp.xcodeproj"
# OR
# workspace_path: "MyApp.xcworkspace"

# Required: Scheme to build
scheme: "MyApp"

# Optional: Build configuration (defaults to "Release")
build_configuration: "Release"

# Signing Configuration
signing:
  # Code signing style: "manual" or "automatic"
  style: "manual"
  
  # Signing identity (certificate name)
  identity: "Apple Distribution: My Company (TEAM123)"
  
  # Development team ID
  team_id: "TEAM123"
  
  # Provisioning Profile (specify exactly ONE)
  provisioning_profile:
    uuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    # OR
    # name: "MyApp Distribution Profile"
    # OR
    # path: "/path/to/profile.mobileprovision"

# Test Configuration
test_targets:
  - "MyAppTests"
  - "MyAppUITests"

# Parallel testing
parallel_testing: true
parallel_testing_workers: 4

# Archive Configuration
archive_path: "./build/MyApp.xcarchive"

# Export Configuration
export_path: "./build"
export_method: "app-store"  # app-store, ad-hoc, enterprise, development
export_options_plist: "./ExportOptions.plist"

# Build output
build_output_path: "./DerivedData"
```

### Field Reference

#### Project Source (Required - Choose One)

- `project_path` (string): Path to .xcodeproj file
- `workspace_path` (string): Path to .xcworkspace file

**Note:** Exactly one of `project_path` or `workspace_path` must be specified.

#### Build Configuration (Required)

- `scheme` (string): Xcode scheme name

#### Optional Build Settings

- `build_configuration` (string): Build configuration name (default: "Release")
- `build_output_path` (string): Custom derived data path

#### Signing Configuration

- `signing.style` (string): "manual" or "automatic"
- `signing.identity` (string): Code signing identity (certificate name)
- `signing.team_id` (string): Development team ID
- `signing.provisioning_profile.uuid` (string): Provisioning profile UUID
- `signing.provisioning_profile.name` (string): Provisioning profile name
- `signing.provisioning_profile.path` (string): Path to .mobileprovision file

**Note:** Exactly one of `uuid`, `name`, or `path` must be specified for provisioning profile.

#### Test Configuration

- `test_targets` (array): List of test target names to run
- `parallel_testing` (boolean): Enable parallel test execution
- `parallel_testing_workers` (integer): Number of parallel test workers

#### Archive and Export

- `archive_path` (string): Output path for .xcarchive
- `export_path` (string): Output directory for exported IPA
- `export_method` (string): Export method - "app-store", "ad-hoc", "enterprise", or "development"
- `export_options_plist` (string): Path to custom exportOptions.plist

## Configuration Precedence

Configuration values are resolved in the following order (highest to lowest priority):

1. CLI flags (highest priority)
2. App Spec YAML values
3. Default values (lowest priority)

This allows you to define base configuration in YAML and override specific values via CLI flags for different environments.

**Example:**

```yaml
# app-spec.yaml
scheme: "MyApp"
build_configuration: "Release"
```

```bash
# Override configuration for debug build
xcode-cli build --spec app-spec.yaml --configuration Debug
```

## Exit Codes

The tool uses distinct exit codes to indicate different error types:

- `0` - Success
- `1` - Configuration error (invalid YAML, missing required fields)
- `2` - Build failure
- `3` - Test failure
- `4` - Archive/Export failure
- `5` - Simulator error
- `6` - App Store Connect error
- `99` - Internal error

## Examples

### CI/CD Pipeline

```bash
#!/bin/bash
set -e

# Validate configuration
xcode-cli validate app-spec.yaml

# Run tests
xcode-cli test --spec app-spec.yaml --parallel

# Create archive
xcode-cli archive --spec app-spec.yaml

# Export IPA
xcode-cli export ./build/MyApp.xcarchive --export-method app-store --export-path ./build

echo "Build complete: ./build/MyApp.ipa"
```

### Local Development

```bash
# Boot simulator
xcode-cli simulator boot "iPhone 15"

# Build and run app
xcode-cli run --project MyApp.xcodeproj --scheme MyApp --destination "platform=iOS Simulator,name=iPhone 15"

# Run tests
xcode-cli test --project MyApp.xcodeproj --scheme MyApp
```

### Multiple Environments

```yaml
# base-spec.yaml
project_path: "MyApp.xcodeproj"
scheme: "MyApp"
```

```bash
# Development build
xcode-cli build --spec base-spec.yaml --configuration Debug

# Staging build
xcode-cli build --spec base-spec.yaml --configuration Staging

# Production build
xcode-cli build --spec base-spec.yaml --configuration Release
```

## Requirements

- macOS 26.0+
- Swift 6.2+

## License

See [LICENSE](./LICENSE) file for details.