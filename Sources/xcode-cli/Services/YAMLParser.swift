import Foundation
import Yams

public struct YAMLParser {
    public init() {}
    
    public func parse(fileURL: URL) throws -> AppSpec {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw YAMLParserError.fileNotFound(fileURL)
        }
        
        let yamlString: String
        let decoder = YAMLDecoder()
        
        do {
            yamlString = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            throw YAMLParserError.fileNotFound(fileURL)
        }
        
        do {
            let spec = try decoder.decode(AppSpec.self, from: yamlString)
            guard spec.scheme != nil else {
                throw YAMLParserError.missingRequiredField("scheme")
            }
            return spec
        } catch let error as YAMLParserError {
            throw error
        } catch let error as DecodingError {
            throw YAMLParserError.fromDecodingError(error)
        } catch {
            throw YAMLParserError.invalidYAML(error.localizedDescription)
        }
    }
    
    public func serialize(_ spec: AppSpec) throws -> String {
        let encoder = YAMLEncoder()
        
        do {
            return try encoder.encode(spec)
        } catch {
            throw YAMLParserError.invalidYAML(
                "Failed to serialize AppSpec: \(error.localizedDescription)"
            )
        }
    }
}

public enum YAMLParserError: Error, Equatable {
    case fileNotFound(URL)
    case invalidYAML(String)
    case missingRequiredField(String)
    case invalidFieldType(field: String, expected: String)
    case conflictingFields([String])
    
    static func fromDecodingError(_ error: DecodingError) -> YAMLParserError {
        switch error {
        case let .keyNotFound(key, _):
            return .missingRequiredField(key.stringValue)
            
        case let .typeMismatch(type, context):
            let fieldName = context.codingPath
                .map { $0.stringValue }
                .joined(separator: ".")
            let expectedType = String(describing: type)
            
            return .invalidFieldType(field: fieldName, expected: expectedType)
            
        case let .valueNotFound(_, context):
            let fieldName = context.codingPath
                .map { $0.stringValue }
                .joined(separator: ".")
            
            return .missingRequiredField(fieldName)
            
        case let .dataCorrupted(context):
            return .invalidYAML(context.debugDescription)
            
        @unknown default:
            return .invalidYAML(error.localizedDescription)
        }
    }
}
