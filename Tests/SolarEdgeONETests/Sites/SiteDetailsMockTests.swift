import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server. Needs network access.
///
/// The spec's Site Details example has no `latitude`, `longitude`,
/// `countryCode` or `timezone`, which the spec does not mark as optional.
/// These tests therefore only check that the mock accepts the requests;
/// decoding is tested offline in ``SiteDetailsDTOTests``.
@Suite(.tags(.mockServer))
struct SiteDetailsMockTests {
    let sites = MockServer.sitesService()
    let missingLocationFields = ExpectedMockFailure.missingKeys(["latitude", "longitude", "countryCode", "timezone"])

    @Test
    func detailsRequestIsAccepted() async {
        await expectAcceptedByMock(allowing: missingLocationFields) {
            try await sites.details(for: 93082)
        }
    }

    @Test
    func detailsAcceptsBearerToken() async {
        let sites = MockServer.sitesService(
            credentials: .bearerToken(StaticTokenProvider(token: "123"))
        )

        await expectAcceptedByMock(allowing: missingLocationFields) {
            try await sites.details(for: 93082)
        }
    }
}
