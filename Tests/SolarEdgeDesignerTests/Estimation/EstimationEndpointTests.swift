import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeDesigner
import SolarEdgeCore

struct EstimationEndpointTests {

    func query(_ endpoint: some Endpoint) -> [String] {
        endpoint.queryItems.map { "\($0.name)=\($0.value ?? "")" }
    }

    @Test
    func pathsMatchTheSpec() {
        #expect(BatteriesEndpoint(manufacturer: nil, phase: nil).path == "batteries")
        #expect(ConsumptionProfilesEndpoint(country: "US").path == "consumption-profiles")
        #expect(GridCodesEndpoint(country: "US").path == "grid-codes")
        #expect(PvModulesEndpoint(manufacturer: nil).path == "pv-modules")
        #expect(PvModuleEndpoint(id: 42).path == "pv-modules/42")
        #expect(UtilityProvidersEndpoint(rateType: nil, country: nil, state: nil).path == "utility-rates/utility-names")
        #expect(UtilityRatesEndpoint(utilityNames: [], rateType: nil, orphanRates: nil, country: nil, state: nil).path == "utility-rates")
        #expect(UtilityRateEndpoint(id: 7).path == "utility-rates/7")
        #expect(IncentivesEndpoint(country: nil, state: nil).path == "incentives")
        #expect(IncentiveEndpoint(id: 9).path == "incentives/9")
    }

    @Test
    func everyEndpointAcceptsBothKeys() {
        let endpoints: [any Endpoint] = [
            BatteriesEndpoint(manufacturer: nil, phase: nil), ConsumptionProfilesEndpoint(country: "US"),
            GridCodesEndpoint(country: "US"), PvModulesEndpoint(manufacturer: nil), PvModuleEndpoint(id: 1),
            UtilityProvidersEndpoint(rateType: nil, country: nil, state: nil),
            UtilityRatesEndpoint(utilityNames: [], rateType: nil, orphanRates: nil, country: nil, state: nil),
            UtilityRateEndpoint(id: 1), IncentivesEndpoint(country: nil, state: nil), IncentiveEndpoint(id: 1),
        ]
        for endpoint in endpoints {
            #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
            #expect(endpoint.method == .get)
        }
    }

    /// `nil` filters are left out, so the API applies its defaults (e.g. `ALL`).
    @Test
    func unsetFiltersAreNotSent() {
        #expect(query(BatteriesEndpoint(manufacturer: nil, phase: nil)).isEmpty)
        #expect(query(PvModulesEndpoint(manufacturer: nil)).isEmpty)
        #expect(query(UtilityProvidersEndpoint(rateType: nil, country: nil, state: nil)).isEmpty)
        #expect(query(UtilityRatesEndpoint(utilityNames: [], rateType: nil, orphanRates: nil, country: nil, state: nil)).isEmpty)
        #expect(query(IncentivesEndpoint(country: nil, state: nil)).isEmpty)
    }

    @Test
    func filtersUseTheSpecNamesAndValues() {
        #expect(query(BatteriesEndpoint(manufacturer: "solaredge", phase: .three)) == ["manufacturer=solaredge", "phase=3"])
        #expect(query(ConsumptionProfilesEndpoint(country: "US")) == ["country=US"])
        #expect(query(GridCodesEndpoint(country: "DE")) == ["country=DE"])
        #expect(query(UtilityProvidersEndpoint(rateType: .export, country: "US", state: "US-NY"))
                == ["rateType=EXPORT_RATE", "country=US", "state=US-NY"])
        #expect(query(IncentivesEndpoint(country: "US", state: "US-NY")) == ["country=US", "state=US-NY"])
    }

    /// One `utilityNames` item per name, so a name with a comma stays intact.
    @Test
    func utilityNamesAreRepeated() {
        let endpoint = UtilityRatesEndpoint(utilityNames: ["Utility Company 1", "Power, Inc."], rateType: .import,
                                            orphanRates: .excludeOrphans, country: "US", state: "US-NY")

        #expect(query(endpoint) == [
            "utilityNames=Utility Company 1", "utilityNames=Power, Inc.",
            "rateType=IMPORT_RATE", "orphanRatesFilter=NON_ORPHAN_RATES", "country=US", "state=US-NY",
        ])
    }

    /// Fails the test if a request is sent.
    struct NoRequestTransport: HTTPTransport {
        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            Issue.record("No request expected, got \(request.url!)")
            throw SolarEdgeError.invalidResponse
        }
    }

    @Test(arguments: ["", "  "])
    func emptyCountryIsRejectedBeforeSending(_ country: String) async {
        let estimation = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL,
                                                 transport: NoRequestTransport()).estimation

        await #expect(throws: SolarEdgeError.self) { try await estimation.consumptionProfiles(country: country) }
        await #expect(throws: SolarEdgeError.self) { try await estimation.gridCodes(country: country) }
    }
}
