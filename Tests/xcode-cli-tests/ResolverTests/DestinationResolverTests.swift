import Testing
@testable import xcode_cli

@Suite("Destination Resolver Tests")
struct DestinationResolverTests {

    @Test("Simulator without OS defaults to latest")
    func simulatorResolutionWithoutOS() throws {
        let resolver = DestinationResolver()
        let result = try resolver.resolve(simulator: "iPhone 15", device: nil, os: nil)
        #expect(result == .simulator(name: "iPhone 15", os: "latest"))
    }

    @Test("Simulator with OS uses provided version")
    func simulatorResolutionWithOS() throws {
        let resolver = DestinationResolver()
        let result = try resolver.resolve(simulator: "iPhone 15", device: nil, os: "17.0")
        #expect(result == .simulator(name: "iPhone 15", os: "17.0"))
    }

    @Test("Device resolves correctly")
    func deviceResolution() throws {
        let resolver = DestinationResolver()
        let result = try resolver.resolve(simulator: nil, device: "My iPhone", os: nil)
        #expect(result == .device(name: "My iPhone"))
    }

    @Test("Conflicting simulator and device flags throws error")
    func conflictingFlagsError() {
        let resolver = DestinationResolver()
        #expect(throws: DestinationResolverError.conflictingFlags) {
            try resolver.resolve(simulator: "iPhone 15", device: "My iPhone", os: nil)
        }
    }

    @Test("OS without simulator throws error")
    func osWithoutSimulatorError() {
        let resolver = DestinationResolver()
        #expect(throws: DestinationResolverError.osWithoutSimulator) {
            try resolver.resolve(simulator: nil, device: nil, os: "17.0")
        }
    }

    @Test("Both nil returns nil")
    func bothNilReturnsNil() throws {
        let resolver = DestinationResolver()
        let result = try resolver.resolve(simulator: nil, device: nil, os: nil)
        #expect(result == nil)
    }

    @Test(
        "Simulator destination resolves with various names and OS versions",
        arguments: [
            ("iPhone 15", "17.0"),
            ("iPhone 14 Pro", "16.4"),
            ("iPad Air", "17.0"),
            ("iPhone SE", "15.5"),
        ]
    )
    func simulatorDestinationResolution(name: String, os: String) throws {
        let resolver = DestinationResolver()
        let result = try resolver.resolve(simulator: name, device: nil, os: os)
        #expect(result == .simulator(name: name, os: os))
    }

    @Test(
        "Device destination resolves with various names",
        arguments: ["My iPhone", "John's iPad", "Test Device", "iPhone 15"]
    )
    func deviceDestinationResolution(name: String) throws {
        let resolver = DestinationResolver()
        let result = try resolver.resolve(simulator: nil, device: name, os: nil)
        #expect(result == .device(name: name))
    }
}
