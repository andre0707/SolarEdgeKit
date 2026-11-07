import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct InventoryEndpointTests {

    @Test
    func inventorySendsOneItemPerTypeInStableOrder() {
        let endpoint = SiteInventoryEndpoint(siteID: 93082, types: [.meter, .battery, .inverter])

        #expect(endpoint.path == "sites/93082/devices")
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "types", value: "INVERTER"),
            URLQueryItem(name: "types", value: "BATTERY"),
            URLQueryItem(name: "types", value: "METER"),
        ])
    }

    @Test
    func deviceInfoPutsTheSerialNumberInThePath() {
        let endpoint = DeviceInfoEndpoint(siteID: 93082, serialNumber: "7E140000-AB")

        #expect(endpoint.path == "sites/93082/devices/7E140000-AB")
        #expect(endpoint.queryItems.isEmpty)
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
    }

    /// Fails before any request is made, so no network is needed.
    @Test
    func rejectsEmptyTypes() async {
        let inventory = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inventory

        await #expect(throws: SolarEdgeError.self) {
            try await inventory.devices(for: 93082, types: [])
        }
    }

    /// Fails before any request is made, so no network is needed.
    @Test(arguments: ["", "7E14/00"])
    func rejectsInvalidSerialNumber(_ serialNumber: String) async {
        let inventory = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inventory

        await #expect(throws: SolarEdgeError.self) {
            try await inventory.device(serialNumber, for: 93082)
        }
    }
}
