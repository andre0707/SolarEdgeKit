import Testing
import Foundation
import SolarEdgeONE

/// Uses only the public API, as an app would.
struct SolarEdgeONEClientTests {

    @Test
    func defaultsToProductionServer() {
        #expect(SolarEdgeONEClient.productionURL.absoluteString == "https://monitoringapi.solaredge.com/v2")
    }
}

/// Sends a real request to the Stoplight mock. Needs network access; its
/// own suite, so `swift test --skip 'Mock(Setup)?Tests'` skips it.
@Suite(.tags(.mockServer))
struct SolarEdgeONEClientMockTests {

    @Test
    func sendsRequestsToTheGivenServer() async throws {
        let client = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL)

        let page = try await client.sites.list()

        #expect(page.sites.first?.id == 93082)
    }
}
