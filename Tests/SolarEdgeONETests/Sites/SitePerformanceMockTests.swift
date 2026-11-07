import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct SitePerformanceMockTests {
    let sites = MockServer.sitesService()

    @Test
    func performanceDecodesExample() async throws {
        let performance = try await sites.performance(for: 93082)

        // The mock always answers with the spec's example, which uses another site ID.
        #expect(performance.siteID == 49212)
        #expect(performance.specificYield == 2.93)
        #expect(performance.performanceRatio == 0.8)
    }

    /// The mock validates `from` and `to` as date-time, so this checks the format.
    @Test
    func performanceAcceptsPeriod() async throws {
        let to = Date()
        let from = to.addingTimeInterval(-24 * 3600)

        _ = try await sites.performance(for: 93082, from: from, to: to)
    }

    @Test
    func performanceAcceptsBearerToken() async throws {
        let sites = MockServer.sitesService(
            credentials: .bearerToken(StaticTokenProvider(token: "123"))
        )

        _ = try await sites.performance(for: 93082)
    }
}
