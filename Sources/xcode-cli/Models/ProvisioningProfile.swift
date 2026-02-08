import Foundation

public struct ProvisioningProfile: Codable, Equatable {
    public let uuid: String?
    public let name: String?
    public let path: String?
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case path
    }
    
    public init(uuid: String? = nil, name: String? = nil, path: String? = nil) {
        self.uuid = uuid
        self.name = name
        self.path = path
    }
}
