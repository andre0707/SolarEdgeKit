import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeDesigner
import SolarEdgeCore

struct DeviceModelsTests {

    @Test
    func endpointSendsGridAndOnlyTheSetFilters() {
        let minimal = DeviceModelsEndpoint(gridID: "g1", countryCode: nil, stateCode: nil, sector: nil)
        let full = DeviceModelsEndpoint(gridID: "g1", countryCode: "US", stateCode: "NY", sector: .residential)

        #expect(minimal.path == "device-models")
        #expect(minimal.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(minimal.queryItems == [URLQueryItem(name: "gridId", value: "g1")])
        #expect(full.queryItems.map { "\($0.name)=\($0.value!)" } == ["gridId=g1", "countryCode=US", "stateCode=NY", "sector=residential"])
    }

    @Test
    func emptyMapsDecode() throws {
        let models = try JSONDecoder().decode(DeviceModelsDTO.self, from: Data(#"{"inverters":{},"optimizers":{},"batteries":{}}"#.utf8)).entity

        #expect(models == Designer.DeviceModels(inverters: [:], optimizers: [:], batteries: [:]))
    }

    /// Fails the test if a request is sent.
    struct NoRequestTransport: HTTPTransport {
        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            Issue.record("No request expected, got \(request.url!)")
            throw SolarEdgeError.invalidResponse
        }
    }

    @Test
    func emptyGridIsRejectedBeforeSending() async {
        let service = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL,
                                              transport: NoRequestTransport()).deviceModels

        await #expect(throws: SolarEdgeError.self) { try await service.models(for: "") }
    }
}

/// Sends real requests to the Stoplight mock of the Designer API. The spec
/// has no example, so the mock generates every field with placeholder values.
/// Needs network access.
@Suite(.tags(.mockServer))
struct DeviceModelsMockTests {

    /// Decodes every field of every model type, including the nested
    /// efficiency tables and constraint lists.
    @Test
    func decodesTheGeneratedResponse() async throws {
        let service = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL).deviceModels

        let models = try await service.models(for: "g1", countryCode: "US", stateCode: "NY", sector: .all)

        let inverter = try #require(models.inverters.values.first)
        let optimizer = try #require(models.optimizers.values.first)
        let battery = try #require(models.batteries.values.first)
        #expect(inverter.type == .synergy)
        #expect(inverter.batteryCompatibility.count == 1)
        #expect(inverter.optimizerStringConstraints.count == 1)
        #expect(optimizer.type == .default)
        #expect(optimizer.mountLocation == .all)
        #expect(battery.connectionType == .serial)
    }

    @Test
    func acceptsADesignerKeyAsBearerToken() async throws {
        let service = SolarEdgeDesignerClient(credentials: .bearerToken(StaticTokenProvider(token: "123")),
                                              baseURL: DesignerMockServer.baseURL).deviceModels

        _ = try await service.models(for: "g1")
    }
}
