import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct MeterTelemetryMockTests {
    let meters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).meters

    @Test
    func siteTelemetryDecodesExample() async throws {
        let telemetry = try await meters.telemetry(for: 93082)

        let meter = try #require(telemetry["M-PROD-001"])
        #expect(meter.productionEnergy?.unit == .wattHour)
        #expect(meter.productionEnergy?.values.map(\.value) == [1500, 1620.5])
        #expect(meter.productionPower?.unit == .watt)
        #expect(meter.productionPower?.values.map(\.value) == [6000, 6480])
        // 2026-01-01T00:00:00Z to 00:30:00Z, from the top of the response
        #expect(meter.productionPower?.period == DateInterval(start: Date(timeIntervalSince1970: 1_767_225_600),
                                                               end: Date(timeIntervalSince1970: 1_767_227_400)))
        #expect(meter.importPower == nil)
    }

    /// Only one serial number: the mock rejects comma-separated lists,
    /// although the spec allows them.
    @Test
    func telemetryForOneMeterDecodesExample() async throws {
        let telemetry = try await meters.telemetry(for: 93082, serialNumbers: ["M-PROD-001"])

        #expect(telemetry["M-PROD-001"]?.productionEnergy?.values.count == 2)
    }

    /// The mock validates `resolution`, `from` and `to` against the spec.
    @Test(arguments: Monitoring.Resolution.allCases)
    func telemetryAcceptsEveryResolution(_ resolution: Monitoring.Resolution) async throws {
        let to = Date()

        _ = try await meters.telemetry(for: 93082, from: to.addingTimeInterval(-6 * 3600), to: to, resolution: resolution)
    }

    @Test
    func telemetryAcceptsBearerToken() async throws {
        let meters = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).meters

        _ = try await meters.telemetry(for: 93082)
    }
}
