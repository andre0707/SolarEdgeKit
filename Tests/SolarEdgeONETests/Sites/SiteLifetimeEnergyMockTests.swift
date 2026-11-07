import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct SiteLifetimeEnergyMockTests {
    let sites = MockServer.sitesService()

    @Test
    func lifetimeEnergyDecodesExample() async throws {
        let lifetime = try await sites.lifetimeEnergy(for: 93082)

        #expect(lifetime.energy == 761985.75)
        #expect(lifetime.unit == .wattHour)
        // 2026-10-06T10:00:22+02:00
        #expect(lifetime.lastUpdateTime == Date(timeIntervalSince1970: 1_791_273_622))
    }

    @Test
    func lifetimeEnergyAcceptsBearerToken() async throws {
        let sites = MockServer.sitesService(
            credentials: .bearerToken(StaticTokenProvider(token: "123"))
        )

        _ = try await sites.lifetimeEnergy(for: 93082)
    }
}
