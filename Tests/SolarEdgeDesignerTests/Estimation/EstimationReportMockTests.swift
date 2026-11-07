import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SolarEdgeDesigner
import SolarEdgeCore

/// Sends real requests to the Stoplight mock of the Designer API, which
/// answers with the spec's example estimation. Needs network access.
@Suite(.tags(.mockServer))
struct EstimationReportMockTests {

    let estimation = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL).estimation

    /// The mock checks the body against the spec, so this also checks the
    /// encoded parameters.
    @Test
    func estimateDecodesTheExample() async throws {
        let result = try await estimation.estimate(exampleParameters)

        #expect(result.installedSystem.installedPower == 12825)
        #expect(result.projectDesign.pvModules == 27)
        #expect(result.simulationResults.treesPlanted == 327)
        #expect(result.estimatedMonthlyEnergy.first?.month == .january)
        #expect(result.detailedFinancialAnalysis.yearlyCashFlowList.first?.year == 2023)
        #expect(result.storageReportData.totalStorageCapacity == 13800)
    }

    @Test
    func estimateWithAllOptionalValues() async throws {
        var parameters = exampleParameters
        parameters.stateCode = "NW"
        parameters.consumption = 7000
        parameters.consumptionProfileID = "double_peak"
        parameters.exportLimit = 5000
        parameters.powerFactor = 1
        parameters.oversizing = 1.1
        parameters.systemType = .threePhase
        parameters.batteries = [.init(batteryID: "SE_HOME_48V_3M", batteryCount: 1)]
        parameters.systemPrice = 50000
        parameters.pricePerWatt = 0.0005
        parameters.systemLifetime = .init(years: 25, discountRate: 0, expectedElectricityPriceIncrease: 0, expectedProductionDegradation: 0.004)
        parameters.useBatteryManagementAlgorithm = false
        parameters.incentives = [6393815952735273]
        parameters.profile = .commercial
        parameters.electricalDesign = .init(inverterModel: "SE10K", optimizerModel: "S440")

        _ = try await estimation.estimate(parameters)
    }

    /// The `400` body (`ModelGenerationErrorResponse`) has a `message`.
    @Test
    func unwiredModulesMessageIsKept() async throws {
        let client = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL,
                                             transport: PreferStatusTransport(status: 400)).estimation
        do {
            _ = try await client.estimate(exampleParameters)
            Issue.record("Expected a 400")
        } catch SolarEdgeError.http(let statusCode, let details) {
            #expect(statusCode == 400)
            #expect(details?.message?.contains("unwired modules") == true)
        }
    }

    /// The mock picks the first `oneOf` branch, the estimation.
    @Test
    func siteEstimation() async throws {
        guard case .ready(let result) = try await estimation.estimation(for: 5) else {
            Issue.record("Expected an estimation")
            return
        }
        #expect(result.billOfMaterials.modules.first?.itemCount != nil)
    }

    @Test
    func siteDesignEstimation() async throws {
        let result = try await estimation.estimation(for: 5, design: 7)

        #expect(result.productionAndConsumption.totalExport > 0)
    }

    @Test
    func acceptsADesignerKeyAsBearerToken() async throws {
        let estimation = SolarEdgeDesignerClient(credentials: .bearerToken(StaticTokenProvider(token: "123")),
                                                 baseURL: DesignerMockServer.baseURL).estimation

        _ = try await estimation.estimate(exampleParameters)
    }
}

/// Asks the mock for the given status with `Prefer: code=…`.
struct PreferStatusTransport: HTTPTransport {
    let status: Int

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        var request = request
        request.setValue("code=\(status)", forHTTPHeaderField: "Prefer")
        return try await URLSessionTransport().send(request)
    }
}
