import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
///
/// The spec's Site Alerts example has no `category`, which the spec does
/// not mark as optional. These tests therefore only check that the mock
/// accepts the requests; decoding is tested offline in ``AlertDTOTests``.
@Suite(.tags(.mockServer))
struct SiteAlertsMockTests {
    let alerts = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).alerts
    let missingCategory = ExpectedMockFailure.missingKeys(["category"])

    @Test
    func alertsRequestIsAccepted() async {
        await expectAcceptedByMock(allowing: missingCategory) {
            try await alerts.list(for: 93082)
        }
    }

    /// The mock validates `page`, `alerts-in-page` and `only-open` against the spec.
    @Test
    func alertsAcceptParameters() async {
        await expectAcceptedByMock(allowing: missingCategory) {
            try await alerts.list(for: 93082, page: 2, pageSize: 100, onlyOpen: false)
        }
    }

    @Test
    func alertsAcceptBearerToken() async {
        let alerts = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).alerts

        await expectAcceptedByMock(allowing: missingCategory) {
            try await alerts.list(for: 93082)
        }
    }
}
