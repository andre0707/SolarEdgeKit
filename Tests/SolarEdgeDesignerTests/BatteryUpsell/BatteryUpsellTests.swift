import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeDesigner
import SolarEdgeCore

let upsellBattery = Designer.BatterySetup(batteryID: "SE_HOME_48V_1M", batteryCount: 1)

/// Everything a Monitoring layout needs for the financials.
let monitoringFinancials = Designer.BatteryUpsellFinancialsParameters(
    batteries: [upsellBattery], utilityImportRateID: 45122875639593, utilityExportRateID: 57348743127784,
    consumption: 7000, consumptionProfileID: "double_peak", systemPrice: 50000
)

/// The spec's example distribution.
let exampleDistribution = Designer.BatteryDistribution(
    distribution: [123456789123456789: upsellBattery],
    replacedInverters: [.init(inverterID: 123456789123456780, oldInverterModel: "SE17k-RES", newInverterModel: "SE10K-RWB48 Home Hub")],
    inverterIDs: [123456789123456780]
)

struct BatteryUpsellTests {

    @Test
    func pathsMatchTheSpec() {
        let request = BatteryUpsellRequestDTO(Designer.BatteryUpsellParameters(batteries: [upsellBattery]))
        let financials = BatteryUpsellFinancialsRequestDTO(monitoringFinancials)

        #expect(BatteryUpsellEndpoint(target: .designerSite(5, design: 7), request: request).path == "sites/5/designs/7/battery-upsell")
        #expect(BatteryUpsellEndpoint(target: .monitoringLayout(9, design: 7), request: request).path == "layouts/9/designs/7/battery-upsell")
        #expect(BatteryUpsellFinancialsEndpoint(target: .designerSite(5, design: 7), request: financials).path == "sites/5/designs/7/battery-upsell/financials")
        #expect(BatteryUpsellFinancialsEndpoint(target: .monitoringLayout(9, design: 7), request: financials).path == "layouts/9/designs/7/battery-upsell/financials")
        #expect(BatteryUpsellEndpoint(target: .designerSite(5, design: 7), request: request).method == .post)
        #expect(BatteryUpsellEndpoint(target: .designerSite(5, design: 7), request: request).supportedAuthentication == [.apiKey, .bearerToken])
    }

    /// Batteries go out as `model` and `quantity`; `nil` values are left out.
    @Test
    func bodyUsesTheSpecNames() throws {
        let data = try JSONEncoder().encode(BatteryUpsellRequestDTO(Designer.BatteryUpsellParameters(batteries: [upsellBattery])))
        let body = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(Set(body.keys) == ["batteries"])
        #expect(body["batteries"] as? [[String: AnyHashable]] == [["model": "SE_HOME_48V_1M", "quantity": 1]])
    }

    /// The example's IDs are above 2^53; they must decode exactly.
    @Test
    func decodesTheExampleWithLargeIDsExactly() throws {
        let json = #"""
        {"batteryDistribution":{"distribution":{"123456789123456789":{"model":"SE_HOME_48V_1M","quantity":1}},
         "replacedInverters":[{"inverterId":123456789123456780,"oldInverterModel":"SE17k-RES","newInverterModel":"SE10K-RWB48 Home Hub"}],
         "inverterIds":[123456789123456780]}}
        """#
        let dto = try JSONDecoder().decode(BatteryUpsellResponseDTO.self, from: Data(json.utf8))

        #expect(try dto.batteryDistribution.entity == exampleDistribution)
        // Looked up by a typed inverter ID, no text conversion needed.
        #expect(try dto.batteryDistribution.entity.distribution[123456789123456789] == upsellBattery)
    }

    /// The API sends the inverter IDs as object keys, i.e. as text.
    @Test
    func rejectsANonNumericInverterKey() throws {
        let json = #"{"batteryDistribution":{"distribution":{"INV-1":{"model":"M","quantity":1}},"replacedInverters":[],"inverterIds":[]}}"#
        let dto = try JSONDecoder().decode(BatteryUpsellResponseDTO.self, from: Data(json.utf8))

        #expect(throws: SolarEdgeError.self) { try dto.batteryDistribution.entity }
    }

    @Test
    func validParametersPass() throws {
        try Designer.BatteryUpsellParameters(batteries: [upsellBattery]).validate()
        try monitoringFinancials.validate(for: .monitoringLayout(9, design: 7))
        // A Designer site needs no financial values.
        try Designer.BatteryUpsellFinancialsParameters(batteries: [upsellBattery]).validate(for: .designerSite(5, design: 7))
        // Price per watt instead of system price, a custom profile instead of an ID.
        var alternative = monitoringFinancials
        alternative.systemPrice = nil
        alternative.pricePerWatt = 0.0005
        alternative.consumptionProfileID = nil
        alternative.consumptionProfile = Array(repeating: 1 / 8760, count: 8760)
        try alternative.validate(for: .monitoringLayout(9, design: 7))
    }

    @Test
    func invalidBatteriesAreRejected() {
        #expect(throws: SolarEdgeError.self) { try Designer.BatteryUpsellParameters(batteries: []).validate() }
        #expect(throws: SolarEdgeError.self) {
            try Designer.BatteryUpsellParameters(batteries: [.init(batteryID: "B", batteryCount: 0)]).validate()
        }
    }

    @Test(arguments: [
        { (p: inout Designer.BatteryUpsellFinancialsParameters) in p.utilityImportRateID = nil },
        { p in p.utilityExportRateID = nil },
        { p in p.consumption = nil },
        { p in p.consumptionProfileID = nil },
        { p in p.systemPrice = nil },
        { p in p.consumption = -1 },
        { p in p.consumptionProfile = [1] },
        { p in p.batteries = [] },
    ] as [@Sendable (inout Designer.BatteryUpsellFinancialsParameters) -> Void])
    func incompleteMonitoringFinancialsAreRejected(_ change: @Sendable (inout Designer.BatteryUpsellFinancialsParameters) -> Void) {
        var parameters = monitoringFinancials
        change(&parameters)

        #expect(throws: SolarEdgeError.self) { try parameters.validate(for: .monitoringLayout(9, design: 7)) }
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
        let service = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL,
                                              transport: NoRequestTransport()).batteryUpsell

        await #expect(throws: SolarEdgeError.self) { try await service.apply(.init(batteries: []), to: .designerSite(5, design: 7)) }
        await #expect(throws: SolarEdgeError.self) {
            try await service.applyWithFinancials(.init(batteries: [upsellBattery]), to: .monitoringLayout(9, design: 7))
        }
    }
}

/// Sends real requests to the Stoplight mock of the Designer API, which
/// checks the bodies against the spec. Needs network access.
@Suite(.tags(.mockServer))
struct BatteryUpsellMockTests {

    let service = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL).batteryUpsell

    @Test(arguments: [Designer.BatteryUpsellTarget.designerSite(5, design: 7), .monitoringLayout(9, design: 7)])
    func applyDecodesTheExample(_ target: Designer.BatteryUpsellTarget) async throws {
        let parameters = Designer.BatteryUpsellParameters(batteries: [upsellBattery], createdBy: "owner@example.com", allowInverterChange: true)

        #expect(try await service.apply(parameters, to: target) == exampleDistribution)
    }

    /// The financials have no example; the mock generates placeholder numbers.
    @Test(arguments: [Designer.BatteryUpsellTarget.designerSite(5, design: 7), .monitoringLayout(9, design: 7)])
    func applyWithFinancials(_ target: Designer.BatteryUpsellTarget) async throws {
        let result = try await service.applyWithFinancials(monitoringFinancials, to: target)

        #expect(result.batteryDistribution == exampleDistribution)
    }

    @Test
    func acceptsADesignerKeyAsBearerToken() async throws {
        let service = SolarEdgeDesignerClient(credentials: .bearerToken(StaticTokenProvider(token: "123")),
                                              baseURL: DesignerMockServer.baseURL).batteryUpsell

        _ = try await service.apply(.init(batteries: [upsellBattery]), to: .designerSite(5, design: 7))
    }
}
