import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct EnvironmentalBenefitsMockTests {
    let sites = MockServer.sitesService()

    /// The mock validates the `unit` query parameter against the spec, so this
    /// checks that both raw values are accepted.
    @Test(arguments: Monitoring.UnitSystem.allCases)
    func environmentalBenefitsDecodes(unit: Monitoring.UnitSystem) async throws {
        let benefits = try await sites.environmentalBenefits(for: 93082, unit: unit)

        // The mock ignores the requested unit and always answers METRIC
        // with placeholder numbers, so only the unit is checked.
        #expect(benefits.unit == .metric)
    }

    @Test
    func environmentalBenefitsAcceptsBearerToken() async throws {
        let sites = MockServer.sitesService(
            credentials: .bearerToken(StaticTokenProvider(token: "123"))
        )

        let benefits = try await sites.environmentalBenefits(for: 93082)

        #expect(benefits.unit == .metric)
    }
}
