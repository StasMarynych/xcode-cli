import Foundation

public struct SimulatorDevice: Codable, Equatable, Sendable {
    public let udid: String
    public let name: String
    public let state: SimulatorState
    public let runtime: String
    
    public init(udid: String, name: String, state: SimulatorState, runtime: String) {
        self.udid = udid
        self.name = name
        self.state = state
        self.runtime = runtime
    }
}

public struct LaunchResult: Equatable, Sendable {
    public let processID: Int
    public let bundleID: String
    
    public init(processID: Int, bundleID: String) {
        self.processID = processID
        self.bundleID = bundleID
    }
}
