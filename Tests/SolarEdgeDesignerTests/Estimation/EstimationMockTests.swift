import Testing
import Foundation
import SolarEdgeDesigner

/// Sends real requests to the Stoplight mock of the Designer API. The spec
/// has no examples here, so the mock generates placeholder values.
/// Needs network access.
@Suite(.tags(.mockServer))
struct EstimationMockTests {

    let estimation = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL).estimation

    @Test
    func batteries() async throws {
        #expect(try await estimation.batteries() == [Designer.Battery(id: "string", capacity: 0, displayName: "string")])
        // The mock validates `phase` against the spec's enum.
        _ = try await estimation.batteries(manufacturer: "solaredge", phase: .three)
        _ = try await estimation.batteries(phase: .single)
    }

    @Test
    func consumptionProfilesAndGridCodes() async throws {
        #expect(try await estimation.consumptionProfiles(country: "US") == [Designer.ConsumptionProfile(id: "string", name: "string")])
        #expect(try await estimation.gridCodes(country: "US")
                == [Designer.GridCode(id: "string", name: "string", onePhaseVoltage: 0, threePhaseVoltage: 0)])
    }

    @Test
    func pvModules() async throws {
        let list = try await estimation.pvModules(manufacturer: "Maker")
        let single = try await estimation.pvModule(1)

        #expect(list.map(\.id) == [0])
        #expect(single.model == "string")
    }

    @Test
    func utilityProvidersAndRates() async throws {
        #expect(try await estimation.utilityProviders(rateType: .import, country: "US", state: "US-NY") == [Designer.UtilityProvider(name: "string")])

        let expected = Designer.UtilityRate(id: 0, utilityName: "string", name: "string", rateType: .export,
                                            effectiveDate: CalendarDate(year: 2019, month: 8, day: 24)!)
        // The mock validates `rateType` and `orphanRatesFilter` against the spec's enums.
        #expect(try await estimation.utilityRates(utilityNames: ["Utility Company 1", "Utility Company 2"], rateType: .export,
                                                  orphanRates: .onlyOrphans, country: "US", state: "US-NY") == [expected])
        #expect(try await estimation.utilityRate(1) == expected)
    }

    @Test
    func incentives() async throws {
        let expected = Designer.Incentive(id: 0, name: "string", summary: "string")

        #expect(try await estimation.incentives(country: "US", state: "US-NY") == [expected])
        #expect(try await estimation.incentive(1) == expected)
    }

    @Test
    func acceptsADesignerKeyAsBearerToken() async throws {
        let estimation = SolarEdgeDesignerClient(credentials: .bearerToken(StaticTokenProvider(token: "123")),
                                                 baseURL: DesignerMockServer.baseURL).estimation

        _ = try await estimation.gridCodes(country: "US")
    }
}
