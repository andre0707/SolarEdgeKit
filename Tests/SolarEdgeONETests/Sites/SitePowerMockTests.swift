import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct SitePowerMockTests {
    let sites = MockServer.sitesService()

    @Test
    func powerDecodesExample() async throws {
        let power = try await sites.power(for: 93082)

        // 2026-10-01T09:00:22+02:00 to 2026-10-01T10:00:22+02:00
        #expect(power.period == DateInterval(
            start: Date(timeIntervalSince1970: 1_790_838_022),
            end: Date(timeIntervalSince1970: 1_790_841_622)
        ))
        #expect(power.unit == .watt)
        #expect(power.resolution == .quarterHour)
        #expect(power.values.map(\.value) == [167.85, 290.89, 491.56, 798.12])
        // 2026-10-01T09:00:00+02:00, then every 15 minutes
        #expect(power.values.map(\.timestamp) == [0, 900, 1800, 2700].map {
            Date(timeIntervalSince1970: 1_790_838_000 + $0)
        })
    }

    /// The mock validates `resolution`, `unit`, `from` and `to` against the spec.
    @Test(arguments: Monitoring.IntradayResolution.allCases, [Monitoring.Power.watt, .kiloWatt, .megaWatt])
    func powerAcceptsParameters(resolution: Monitoring.IntradayResolution, unit: Monitoring.Power) async throws {
        let to = Date()
        let from = to.addingTimeInterval(-6 * 3600)

        _ = try await sites.power(for: 93082, from: from, to: to, resolution: resolution, unit: unit)
    }

    @Test
    func powerAcceptsBearerToken() async throws {
        let sites = MockServer.sitesService(
            credentials: .bearerToken(StaticTokenProvider(token: "123"))
        )

        _ = try await sites.power(for: 93082)
    }
}
