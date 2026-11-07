import Testing
import Foundation
@testable import SolarEdgeONE

struct SitePerformanceEndpointTests {

    @Test
    func omitsPeriodWhenNotGiven() {
        let endpoint = SitePerformanceEndpoint(siteID: 93082, from: nil, to: nil)

        #expect(endpoint.path == "sites/93082/overview/performance")
        #expect(endpoint.queryItems.isEmpty)
    }

    @Test
    func sendsPeriodInUTC() {
        let endpoint = SitePerformanceEndpoint(
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
