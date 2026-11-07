import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeDesigner
import SolarEdgeCore

/// The spec's example parameters.
let exampleParameters = Designer.EstimationParameters(
    longitude: 7.2561046,
    latitude: 51.6123927,
    countryCode: "DE",
    gridID: "230",
    pvModuleSetup: [.init(pvModuleID: 19676, pvModuleCount: 50, panelDirection: .init(azimuth: 0, tilt: 20), mountType: .flushMount)],
    utilityImportRateID: 45122875639593,
    utilityExportRateID: 57348743127784,
    shadingFactor: 0
)

struct EstimationReportEndpointTests {

    @Test
    func pathsAndMethodsMatchTheSpec() {
        let generate = GenerateEstimationEndpoint(parameters: EstimationParamsDTO(exampleParameters))
        let site = SiteEstimationEndpoint(siteID: 5)
        let design = SiteDesignEstimationEndpoint(siteID: 5, designID: 7)

        #expect(generate.path == "estimation")
        #expect(generate.method == .post)
        #expect(site.path == "report/sites/5")
        #expect(site.method == .get)
        #expect(design.path == "report/sites/5/designs/7")
        for endpoint in [generate, site, design] as [any Endpoint] {
            #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
        }
    }

    func json(_ parameters: Designer.EstimationParameters) throws -> [String: Any] {
        let data = try JSONEncoder().encode(EstimationParamsDTO(parameters))
        return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    /// Only the required keys; `nil` values are left out, not sent as `null`.
    @Test
    func minimalBodyHasOnlyTheRequiredKeys() throws {
        let body = try json(exampleParameters)

        #expect(Set(body.keys) == ["longitude", "latitude", "countryCode", "gridId", "pvModuleSetup",
                                   "utilityImportRateId", "utilityExportRateId", "shadingFactor"])
        #expect(body["gridId"] as? String == "230")
        #expect(body["utilityImportRateId"] as? Int == 45122875639593)
        let setup = try #require((body["pvModuleSetup"] as? [[String: Any]])?.first)
        #expect(setup["pvModuleId"] as? Int == 19676)
        #expect(setup["mountType"] as? String == "FLUSH_MOUNT")
        #expect((setup["panelDirection"] as? [String: Any])?["tilt"] as? Double == 20)
    }

    @Test
    func optionalValuesUseTheSpecNames() throws {
        var parameters = exampleParameters
        parameters.stateCode = "NW"
        parameters.consumptionProfileID = "double_peak"
        parameters.systemType = .threePhase
        parameters.batteries = [.init(batteryID: "SE_HOME_48V_3M", batteryCount: 1)]
        parameters.systemLifetime = .init(years: 20)
        parameters.useBatteryManagementAlgorithm = true
        parameters.incentives = [6393815952735273]
        parameters.profile = .residential
        parameters.electricalDesign = .init(inverterModel: "SE10K")

        let body = try json(parameters)

        #expect(body["stateCode"] as? String == "NW")
        #expect(body["consumptionProfileId"] as? String == "double_peak")
        #expect(body["systemType"] as? String == "3Phase")
        #expect(body["batteries"] as? [[String: AnyHashable]] == [["batteryCount": 1, "batteryId": "SE_HOME_48V_3M"]])
        #expect(body["systemLifetime"] as? [String: Int] == ["years": 20])
        #expect(body["useBma"] as? Bool == true)
        #expect(body["incentives"] as? [Int] == [6393815952735273])
        #expect(body["profile"] as? String == "RESIDENTIAL")
        #expect(body["electricalDesign"] as? [String: String] == ["inverterModel": "SE10K"])
    }

    @Test
    func exampleParametersAreValid() throws {
        try exampleParameters.validate()
    }

    @Test(arguments: [
        { (p: inout Designer.EstimationParameters) in p.longitude = 181 },
        { p in p.latitude = -91 },
        { p in p.countryCode = "" },
        { p in p.gridID = "" },
        { p in p.consumption = -1 },
        { p in p.consumptionProfile = Array(repeating: 1 / 8760, count: 8759) },
        { p in p.consumptionProfile = [-1] + Array(repeating: 0, count: 8759) },
        { p in p.exportLimit = -1 },
        { p in p.powerFactor = 0.7 },
        { p in p.pvModuleSetup = [] },
        { p in p.pvModuleSetup[0].pvModuleCount = 0 },
        { p in p.pvModuleSetup[0].panelDirection.azimuth = 360 },
        { p in p.pvModuleSetup[0].panelDirection.tilt = 81 },
        { p in p.oversizing = 2.1 },
        { p in p.batteries = [.init(batteryID: "B", batteryCount: 0)] },
        { p in p.systemLifetime = .init(discountRate: 1.5) },
        { p in p.systemLifetime = .init(expectedProductionDegradation: -0.1) },
        { p in p.shadingFactor = 1.1 },
    ] as [@Sendable (inout Designer.EstimationParameters) -> Void])
    func outOfRangeValuesAreRejected(_ change: @Sendable (inout Designer.EstimationParameters) -> Void) {
        var parameters = exampleParameters
        change(&parameters)

        #expect(throws: SolarEdgeError.self) { try parameters.validate() }
    }

    @Test
    func validProfileIsAccepted() throws {
        var parameters = exampleParameters
        parameters.consumptionProfile = Array(repeating: 1 / 8760, count: 8760)

        try parameters.validate()
    }

    /// Fails the test if a request is sent.
    struct NoRequestTransport: HTTPTransport {
        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            Issue.record("No request expected, got \(request.url!)")
            throw SolarEdgeError.invalidResponse
        }
    }

    @Test
    func invalidParametersAreRejectedBeforeSending() async {
        var parameters = exampleParameters
        parameters.shadingFactor = 2
        let estimation = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL,
                                                 transport: NoRequestTransport()).estimation

        await #expect(throws: SolarEdgeError.self) { try await estimation.estimate(parameters) }
    }
}

struct EstimationResultDTOTests {

    @Test
    func stillInDesignMessageIsRecognized() throws {
        let dto = try JSONDecoder().decode(SiteEstimationDTO.self,
                                           from: Data(#"{"siteStillInDesignMessage":"Site is still in design. The progress is: 0.5."}"#.utf8))

        #expect(try dto.entity == .stillInDesign(message: "Site is still in design. The progress is: 0.5."))
    }

    @Test
    func monthsAreNumberedInOrder() {
        #expect(Designer.Estimation.Month.january.number == 1)
        #expect(Designer.Estimation.Month.december.number == 12)
    }

    @Test
    func rejectsAnUnknownMonth() throws {
        let dto = try JSONDecoder().decode(EstimatedMonthlyEnergyItemDTO.self,
                                           from: Data(#"{"month":"Jan","solarProduction":1,"consumption":1,"selfConsumption":1}"#.utf8))

        #expect(throws: SolarEdgeError.self) { try dto.entity }
    }
}
