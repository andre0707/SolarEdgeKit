import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct SiteEnergyMockTests {
    let sites = MockServer.sitesService()

    @Test
    func energyDecodesExample() async throws {
        let energy = try await sites.energy(for: 93082)

        // 2026-10-01T09:00:22+02:00 to 2026-10-06T10:00:22+02:00
        #expect(energy.period == DateInterval(
            start: Date(timeIntervalSince1970: 1_790_838_022),
            end: Date(timeIntervalSince1970: 1_791_273_622)
        ))
        // The mock always answers with the spec's example, whatever was requested.
        #expect(energy.resolution == .day)
        #expect(energy.unit == .wattHour)
        // 2026-10-01T09:15:00+02:00
        #expect(energy.values == [
            Monitoring.MeasurementValue(timestamp: Date(timeIntervalSince1970: 1_790_838_900), value: 0),
        ])
    }

    /// The mock validates `resolution`, `unit`, `from` and `to` against the spec.
    @Test(arguments: Monitoring.Resolution.allCases, [Monitoring.Energy.wattHour, .kiloWattHour, .megaWattHour])
    func energyAcceptsParameters(resolution: Monitoring.Resolution, unit: Monitoring.Energy) async throws {
        let to = Date()
        let from = to.addingTimeInterval(-6 * 3600)

        _ = try await sites.energy(for: 93082, from: from, to: to, resolution: resolution, unit: unit)
    }

    @Test
    func energyAcceptsBearerToken() async throws {
        let sites = MockServer.sitesService(
            credentials: .bearerToken(StaticTokenProvider(token: "123"))
        )

        _ = try await sites.energy(for: 93082)
    }
}
