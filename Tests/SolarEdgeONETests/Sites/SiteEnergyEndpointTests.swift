import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct SiteEnergyEndpointTests {

    @Test
    func sendsResolutionAndUnitWithoutPeriod() {
        let endpoint = SiteEnergyEndpoint(siteID: 93082, from: nil, to: nil, resolution: .quarterHour, unit: .wattHour)

        #expect(endpoint.path == "sites/93082/energy")
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "resolution", value: "QUARTER_HOUR"),
            URLQueryItem(name: "unit", value: "WH"),
        ])
    }

    @Test
    func sendsPeriodInUTC() {
        let endpoint = SiteEnergyEndpoint(
            siteID: 93082,
            from: Date(timeIntervalSince1970: 1_790_812_800),
            to: Date(timeIntervalSince1970: 1_790_899_200),
            resolution: .day,
            unit: .kiloWattHour
        )

        #expect(endpoint.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-02T00:00:00Z"),
            URLQueryItem(name: "resolution", value: "DAY"),
            URLQueryItem(name: "unit", value: "KWH"),
        ])
    }

    /// Fails before any request is made, so no network is needed.
    @Test
    func rejectsGigaWattHour() async {
        let sites = MockServer.sitesService()

        await #expect(throws: SolarEdgeError.self) {
            try await sites.energy(for: 93082, unit: .gigaWattHour)
        }
    }

    /// Fails before any request is made, so no network is needed.
    @Test
    func rejectsPeriodLongerThanAllowed() async {
        let sites = MockServer.sitesService()
        let from = Date(timeIntervalSince1970: 1_790_812_800)

        await #expect(throws: SolarEdgeError.self) {
            try await sites.energy(for: 93082, from: from, to: from.addingTimeInterval(32 * 24 * 3600), resolution: .day)
        }
    }
}
