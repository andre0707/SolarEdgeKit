import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
///
/// The spec has no examples for these endpoints, so the mock generates a
/// device from the schema with placeholder values (`"string"` etc.).
@Suite(.tags(.mockServer))
struct InventoryMockTests {
    let inventory = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inventory

    @Test
    func devicesDecodeGeneratedResponse() async throws {
        let devices = try await inventory.devices(for: 93082)

        let device = try #require(devices.first)
        #expect(device.type == .inverter)
        #expect(device.firmware == "4.25.15.1.100.2059.2.100.1751")
        #expect(device.meterType == "FeedIn")
        #expect(device.communicationType == .wifi)
    }

    /// The mock validates every `types` value against the spec.
    @Test
    func devicesAcceptAllTypes() async throws {
        _ = try await inventory.devices(for: 93082, types: Set(Monitoring.DeviceType.allCases))
    }

    @Test
    func deviceInfoDecodesGeneratedResponse() async throws {
        let device = try await inventory.device("7E140000-AB", for: 93082)

        // 2026-10-01T13:30:00+03:00
        #expect(device.createdAt == Date(timeIntervalSince1970: 1_790_850_600))
        #expect(device.parent?.type == .inverter)
    }

    @Test
    func inventoryAcceptsBearerToken() async throws {
        let inventory = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).inventory

        _ = try await inventory.devices(for: 93082)
    }
}
