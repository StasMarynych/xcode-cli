import Foundation

protocol DestinationResolverProtocol {
    func resolve(simulator: String?, device: String?, os: String?) throws -> Destination?
}

struct DestinationResolver: DestinationResolverProtocol {
    func resolve(simulator: String?, device: String?, os: String?) throws -> Destination? {
        if simulator != nil && device != nil {
            throw DestinationResolverError.conflictingFlags
        }
        if os != nil && simulator == nil {
            throw DestinationResolverError.osWithoutSimulator
        }
        if let simulator {
            return .simulator(name: simulator, os: os ?? "latest")
        }
        if let device {
            return .device(name: device)
        }
        return nil
    }
}
