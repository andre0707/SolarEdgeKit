import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct SiteExternalProductionEnergyMockTests {
    let sites = MockServer.sitesService()

    @Test
    func externalProductionEnergyDecodesExample() async throws {
        let energy = try await sites.externalProductionEnergy(for: 93082)

        #expect(energy.energyIncludingExternalSources == 761985.75)
        #expect(energy.energyExcludingExternalSources == 700000)
        #expect(energy.unit == .wattHour)
    }

    @Test
    func externalProductionEnergyAcceptsBearerToken() async throws {
        let sites = MockServer.sitesService(
            credentials: .bearerToken(StaticTokenProvider(token: "123"))
        )

        _ = try await sites.externalProductionEnergy(for: 93082)
    }
}
