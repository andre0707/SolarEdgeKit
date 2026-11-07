import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeONE
import SolarEdgeCore

struct SerialNumberValidationTests {

    @Test(arguments: ["BE1002D3-A3", "7E123456-5B", "A.B", "..A"])
    func acceptsSerialNumbers(_ serialNumber: String) throws {
        try validateSerialNumber(serialNumber)
    }

    /// `.` and `..` would be read as path segments: `…/inverters/../power`
    /// is the site's power endpoint.
    @Test(arguments: ["", ".", "..", "A/B", "A,B"])
    func rejectsWhatWouldChangeThePath(_ serialNumber: String) {
        #expect(throws: SolarEdgeError.self) { try validateSerialNumber(serialNumber) }
    }

    /// Fails the test if a request is sent.
    struct NoRequestTransport: HTTPTransport {
        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            Issue.record("No request expected, got \(request.url!)")
            throw SolarEdgeError.invalidResponse
        }
    }

    /// The inventory used to have its own, weaker check.
    @Test(arguments: ["..", "A,B"])
    func inventoryUsesTheSameCheck(_ serialNumber: String) async {
        let inventory = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL,
                                           transport: NoRequestTransport()).inventory

        await #expect(throws: SolarEdgeError.self) { try await inventory.device(serialNumber, for: 1) }
    }
}
