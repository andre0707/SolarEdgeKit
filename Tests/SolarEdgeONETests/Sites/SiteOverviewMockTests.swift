import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct SiteOverviewMockTests {
    let sites = MockServer.sitesService()

    @Test
    func overviewDecodesExample() async throws {
        let overview = try await sites.overview(for: 93082)

        // The mock always answers with the spec's example, which uses another site ID.
        #expect(overview.siteID == 49212)

        #expect(overview.production.total == 18.01)
        #expect(overview.production.unit == .wattHour)
        #expect(overview.production.toSelfConsumption == 9.98)
        #expect(overview.production.toStorage == 7.96)
        #expect(overview.production.toGrid == 0.07)

        #expect(overview.consumption.total == 20.41)
        #expect(overview.consumption.unit == .wattHour)
        #expect(overview.consumption.fromPv == 9.98)
        #expect(overview.consumption.fromStorage == 10.01)
        #expect(overview.consumption.fromGrid == 0.42)
    }

    /// The mock validates `from` and `to` as date-time, so this checks the format.
    @Test
    func overviewAcceptsPeriod() async throws {
        let to = Date()
        let from = to.addingTimeInterval(-24 * 3600)

        _ = try await sites.overview(for: 93082, from: from, to: to)
    }

    @Test
    func overviewAcceptsBearerToken() async throws {
        let sites = MockServer.sitesService(
            credentials: .bearerToken(StaticTokenProvider(token: "123"))
        )

        _ = try await sites.overview(for: 93082)
    }
}
