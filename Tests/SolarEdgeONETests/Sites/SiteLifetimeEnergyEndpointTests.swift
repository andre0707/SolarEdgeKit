import Testing
import Foundation
@testable import SolarEdgeONE

struct SiteLifetimeEnergyEndpointTests {

    @Test
    func hasPathAndNoQuery() {
        let endpoint = SiteLifetimeEnergyEndpoint(siteID: 93082)

        #expect(endpoint.path == "sites/93082/lifetime-energy")
        #expect(endpoint.queryItems.isEmpty)
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
    }
}
