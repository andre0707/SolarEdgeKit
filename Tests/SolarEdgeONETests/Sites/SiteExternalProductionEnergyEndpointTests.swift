import Testing
import Foundation
@testable import SolarEdgeONE

struct SiteExternalProductionEnergyEndpointTests {

    @Test
    func hasPathAndNoQuery() {
        let endpoint = SiteExternalProductionEnergyEndpoint(siteID: 93082)

        #expect(endpoint.path == "sites/93082/external-production-energy")
        #expect(endpoint.queryItems.isEmpty)
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
    }
}
