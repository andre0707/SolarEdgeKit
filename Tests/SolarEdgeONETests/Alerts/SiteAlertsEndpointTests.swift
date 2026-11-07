import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct SiteAlertsEndpointTests {

    @Test
    func sendsPagingAndOpenFilter() {
        let endpoint = SiteAlertsEndpoint(siteID: 93082, page: 2, pageSize: 100, onlyOpen: false)

        #expect(endpoint.path == "sites/93082/alerts")
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "page", value: "2"),
            URLQueryItem(name: "alerts-in-page", value: "100"),
            URLQueryItem(name: "only-open", value: "false"),
        ])
    }

    /// Fails before any request is made, so no network is needed.
    @Test(arguments: [(0, 50), (1, 0), (1, 101), (10_000_001, 50)])
    func rejectsOutOfRangePaging(page: Int, pageSize: Int) async {
        let alerts = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).alerts

        await #expect(throws: SolarEdgeError.self) {
            try await alerts.list(for: 93082, page: page, pageSize: pageSize)
        }
    }
}
