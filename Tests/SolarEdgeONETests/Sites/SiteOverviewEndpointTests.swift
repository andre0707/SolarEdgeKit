import Testing
import Foundation
@testable import SolarEdgeONE

struct SiteOverviewEndpointTests {

    @Test
    func omitsPeriodWhenNotGiven() {
        let endpoint = SiteOverviewEndpoint(siteID: 93082, from: nil, to: nil)

        #expect(endpoint.path == "sites/93082/overview")
        #expect(endpoint.queryItems.isEmpty)
    }

    @Test
    func sendsPeriodInUTC() {
        // 2026-10-01T03:00:00+03:00 and 2026-10-02T03:00:00+03:00
        let endpoint = SiteOverviewEndpoint(
            siteID: 93082,
            from: Date(timeIntervalSince1970: 1_790_812_800),
            to: Date(timeIntervalSince1970: 1_790_899_200)
        )

        #expect(endpoint.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-02T00:00:00Z"),
        ])
    }
}
