import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct InverterTelemetryMockTests {
    let inverters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inverters

    @Test
    func siteTelemetryDecodesExample() async throws {
        let telemetry = try await inverters.telemetry(for: 93082)

        let inverter = try #require(telemetry["7E1234B5-67"])
        #expect(inverter.power?.unit == .watt)
        #expect(inverter.power?.resolution == .quarterHour)
        #expect(inverter.power?.values.map(\.value) == [4250.3, 4310.7])
        // 2026-01-01T00:00:00Z and 00:15:00Z
        #expect(inverter.power?.values.map(\.timestamp) == [
            Date(timeIntervalSince1970: 1_767_225_600),
            Date(timeIntervalSince1970: 1_767_226_500),
        ])
        #expect(inverter.energy?.unit == .wattHour)
        #expect(inverter.energy?.values.map(\.value) == [1062.6, 1077.7])
        // The example has no other metrics.
        #expect(inverter.voltage == nil)
    }

    /// Only one serial number: the mock rejects comma-separated lists,
    /// although the spec allows them.
    @Test
    func telemetryForOneInverterDecodesExample() async throws {
        let telemetry = try await inverters.telemetry(for: 93082, serialNumbers: ["7E1234B5-67"])

        #expect(telemetry["7E1234B5-67"]?.power?.values.count == 2)
    }

    /// The mock validates `resolution`, `from` and `to` against the spec.
    @Test(arguments: Monitoring.Resolution.allCases)
    func telemetryAcceptsEveryResolution(_ resolution: Monitoring.Resolution) async throws {
        let to = Date()
        let from = to.addingTimeInterval(-6 * 3600)

        _ = try await inverters.telemetry(for: 93082, from: from, to: to, resolution: resolution)
    }

    @Test
    func telemetryAcceptsBearerToken() async throws {
        let inverters = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).inverters

        _ = try await inverters.telemetry(for: 93082)
    }
}
