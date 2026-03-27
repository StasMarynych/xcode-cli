import Foundation
import Testing
@testable import xcode_cli

@Suite("Merger Property Tests")
struct MergerPropertyTests {

    @Test("Spec values propagate to xcodebuild arguments")
    func specValuesPropagateToXcodebuildArguments() throws {
        let executor = CommandExecutor(processRunner: MockProcessRunner())
        let schemes = ["MyApp", "Production", "Debug", "Release"]
        let identities = ["Apple Distribution", "iPhone Distribution", "Apple Development"]
        let teamIDs = ["TEAM123456", "ABCDEF1234", "XYZ9876543"]

        for _ in 0..<50 {
            let scheme = schemes.randomElement()!
            let identity = identities.randomElement()!
            let teamID = teamIDs.randomElement()!
            let projectPath = "MyApp\(Int.random(in: 1...99)).xcodeproj"

            let config = Configuration(
                projectPath: projectPath,
                scheme: scheme,
                buildConfiguration: "Release",
                destination: .generic(platform: "iOS"),
                signing: SigningConfiguration(style: .manual, identity: identity, teamID: teamID)
            )

            let args = executor.buildXcodeBuildArguments(action: .build, config: config)

            #expect(args.contains("-project"))
            #expect(args.contains(projectPath))
            #expect(args.contains("-scheme"))
            #expect(args.contains(scheme))
            #expect(args.contains("CODE_SIGN_IDENTITY=\(identity)"))
            #expect(args.contains("DEVELOPMENT_TEAM=\(teamID)"))
        }
    }

    @Test("CLI flag overrides spec value")
    func cliFlagonOverridesSpecValue() throws {
        let merger = ConfigurationMerger()
        let schemes = ["SpecScheme", "FlagScheme", "OverrideScheme"]
        let configs = ["Debug", "Release", "Staging"]

        for _ in 0..<50 {
            let specScheme = schemes.randomElement()!
            let flagScheme = schemes.filter { $0 != specScheme }.randomElement()!
            let specConfig = configs.randomElement()!
            let flagConfig = configs.filter { $0 != specConfig }.randomElement()!

            let spec = AppSpec(
                projectPath: "MyApp.xcodeproj",
                scheme: specScheme,
                buildConfiguration: specConfig
            )
            let flags = CommandFlags(
                project: "MyApp.xcodeproj",
                scheme: flagScheme,
                configuration: flagConfig
            )

            let config = try merger.merge(spec: spec, flags: flags)

            #expect(config.scheme == flagScheme)
            #expect(config.buildConfiguration == flagConfig)
        }
    }

    @Test("Missing required field throws MergerError")
    func missingRequiredFieldError() {
        let merger = ConfigurationMerger()

        for _ in 0..<50 {
            let flags = CommandFlags(
                scheme: nil,
                configuration: Bool.random() ? "Release" : nil
            )

            #expect(throws: MergerError.self) {
                try merger.merge(spec: nil, flags: flags)
            }
        }
    }

    @Test("AppSpec serialization round-trip preserves all fields")
    func appSpecSerializationRoundTrip() throws {
        let parser = YAMLParser()

        for _ in 0..<50 {
            let original = AppSpecGenerator.randomWithScheme()
            let yaml = try parser.serialize(original)
            let decoded = try parser.parse(fileURL: writeToTempFile(yaml))
            #expect(decoded == original)
        }
    }

    private func writeToTempFile(_ content: String) throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("yml")
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
