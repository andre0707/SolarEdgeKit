import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct SitePowerEndpointTests {

    @Test
    func sendsResolutionAndUnitWithoutPeriod() {
        let endpoint = SitePowerEndpoint(siteID: 93082, from: nil, to: nil, resolution: .quarterHour, unit: .watt)

        #expect(endpoint.path == "sites/93082/power")
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "resolution", value: "QUARTER_HOUR"),
            URLQueryItem(name: "unit", value: "W"),
        ])
    }

    @Test
    func sendsPeriodInUTC() {
        let endpoint = SitePowerEndpoint(
            siteID: 93082,
            from: Date(timeIntervalSince1970: 1_790_812_800),
            to: Date(timeIntervalSince1970: 1_790_856_000),
            resolution: .hour,
            unit: .kiloWatt
        )

        #expect(endpoint.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-01T12:00:00Z"),
            URLQueryItem(name: "resolution", value: "HOUR"),
            URLQueryItem(name: "unit", value: "KW"),
        ])
    }

    /// Fails before any request is made, so no network is needed.
    @Test(arguments: [
        (Monitoring.IntradayResolution.quarterHour, 12.5),
        (Monitoring.IntradayResolution.hour, 24.5),
    ])
    func rejectsPeriodLongerThanAllowed(resolution: Monitoring.IntradayResolution, hours: Double) async {
        let sites = MockServer.sitesService()
        let from = Date(timeIntervalSince1970: 1_790_812_800)

        await #expect(throws: SolarEdgeError.self) {
            try await sites.power(for: 93082, from: from, to: from.addingTimeInterval(hours * 3600), resolution: resolution)
        }
    }
}
