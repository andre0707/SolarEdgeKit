import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct FleetAlertsEndpointTests {

    @Test
    func sendsOnlyPagingWithoutFilter() {
        let endpoint = FleetAlertsEndpoint(filter: Monitoring.AlertFilter(), page: 1, pageSize: 50, onlyOpen: true)

        #expect(endpoint.path == "alerts")
        #expect(endpoint.supportedAuthentication == [.apiKey])
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "alerts-in-page", value: "50"),
            URLQueryItem(name: "only-open", value: "true"),
        ])
    }

    @Test
    func sendsAllFilters() {
        let filter = Monitoring.AlertFilter(
            group: UUID(uuidString: "3F2504E0-4F89-11D3-9A0C-0305E82C3301"),
            type: "DC Isolation",
            state: "WI",
            city: "Green Bay"
        )
        let endpoint = FleetAlertsEndpoint(filter: filter, page: 2, pageSize: 100, onlyOpen: false)

        #expect(endpoint.queryItems == [
            URLQueryItem(name: "page", value: "2"),
            URLQueryItem(name: "alerts-in-page", value: "100"),
            URLQueryItem(name: "only-open", value: "false"),
            URLQueryItem(name: "group", value: "3f2504e0-4f89-11d3-9a0c-0305e82c3301"),
            URLQueryItem(name: "type", value: "DC Isolation"),
            URLQueryItem(name: "state", value: "WI"),
            URLQueryItem(name: "city", value: "Green Bay"),
        ])
    }

    /// Fails before any request is made, so no network is needed.
    @Test
    func rejectsBearerToken() async {
        let alerts = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).alerts

        await #expect(throws: SolarEdgeError.self) {
            try await alerts.list()
        }
    }

    /// Fails before any request is made, so no network is needed.
    @Test(arguments: [(0, 50), (1, 0), (1, 101), (10_000_001, 50)])
    func rejectsOutOfRangePaging(page: Int, pageSize: Int) async {
        let alerts = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).alerts

        await #expect(throws: SolarEdgeError.self) {
            try await alerts.list(page: page, pageSize: pageSize)
        }
    }
}
