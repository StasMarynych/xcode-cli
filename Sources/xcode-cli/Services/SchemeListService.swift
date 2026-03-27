import Foundation

protocol SchemeListServiceProtocol {
    func listSchemes(for reference: ProjectReference) async throws -> [String]
}

struct XcodebuildSchemeListService: SchemeListServiceProtocol {
    var processRunner: ProcessRunnerProtocol = ProcessRunner()

    func listSchemes(for reference: ProjectReference) async throws -> [String] {
        let flag: String
        switch reference {
        case .workspace: flag = "-workspace"
        case .project: flag = "-project"
        }

        let result = try await self.processRunner.run(
            executable: "xcodebuild",
            arguments: [flag, reference.path, "-list"],
            streamOutput: false
        )

        return parseSchemes(from: result.stdout)
    }

    private func parseSchemes(from output: String) -> [String] {
        var schemes: [String] = []
        var inSchemesSection = false

        for line in output.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "Schemes:" {
                inSchemesSection = true
                continue
            }
            if inSchemesSection {
                if trimmed.isEmpty || trimmed.hasSuffix(":") {
                    break
                }
                schemes.append(trimmed)
            }
        }

        return schemes
    }
}
