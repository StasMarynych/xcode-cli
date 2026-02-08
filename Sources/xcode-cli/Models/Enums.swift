import Foundation

public enum CodeSignStyle: String, Codable, Sendable {
    case automatic
    case manual
}

public enum ExportMethod: String, Codable, Sendable {
    case appStore = "app-store"
    case adHoc = "ad-hoc"
    case enterprise
    case development
}

public enum Destination: Codable, Equatable {
    case simulator(name: String, os: String)
    case device(name: String)
    case generic(platform: String)
    
    enum CodingKeys: String, CodingKey {
        case type
        case name
        case os
        case platform
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "simulator":
            let name = try container.decode(String.self, forKey: .name)
            let os = try container.decode(String.self, forKey: .os)
            self = .simulator(name: name, os: os)
            
        case "device":
            let name = try container.decode(String.self, forKey: .name)
            self = .device(name: name)
            
        case "generic":
            let platform = try container.decode(String.self, forKey: .platform)
            self = .generic(platform: platform)
            
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Invalid destination type: \(type)"
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .simulator(let name, let os):
            try container.encode("simulator", forKey: .type)
            try container.encode(name, forKey: .name)
            try container.encode(os, forKey: .os)
            
        case .device(let name):
            try container.encode("device", forKey: .type)
            try container.encode(name, forKey: .name)
            
        case .generic(let platform):
            try container.encode("generic", forKey: .type)
            try container.encode(platform, forKey: .platform)
        }
    }
}

public enum SimulatorState: String, Codable, Sendable {
    case shutdown = "Shutdown"
    case booted = "Booted"
    case booting = "Booting"
    case shuttingDown = "Shutting Down"
}
