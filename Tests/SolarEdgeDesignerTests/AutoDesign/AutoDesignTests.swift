import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeDesigner
import SolarEdgeCore

let exampleAutoDesign = Designer.AutoDesignParameters(site: .init(siteName: "Test Site", latitude: 51.6123927, longitude: 7.2561046))

let fullAutoDesign = Designer.AutoDesignParameters(
    site: .init(siteName: "Test Site", latitude: 51.6123927, longitude: 7.2561046, sector: .residential, gridID: "240"),
    consumption: .init(utilityRateID: 1, annualConsumptionKwh: 7000, consumptionProfileID: "double_peak"),
    pvPlacement: .init(moduleModelID: 19676, racking: .tilted, orientation: .landscape, tiltDegrees: 20, columnSpacing: 0.1,
                       rowSpacing: 0.2, elevation: 0, maxColumns: 5, maxRows: 4, horizontalSpacing: 0.5, verticalSpacing: 0.5,
                       setbackProfileID: 3, obstacleSpacing: 0.3, frameSize: 1),
    phase: .three,
    pricePerWatt: 1.2
)

struct AutoDesignTests {

    @Test
    func endpointsMatchTheSpec() {
        let create = CreateAutoDesignEndpoint(parameters: AutoDesignParametersDTO(exampleAutoDesign))
        let status = AutoDesignStatusEndpoint(requestID: "req-1")

        #expect(create.path == "auto-design")
        #expect(create.method == .post)
        #expect(status.path == "auto-design/status")
        #expect(status.method == .get)
        #expect(status.queryItems == [URLQueryItem(name: "requestId", value: "req-1")])
        #expect(create.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(status.supportedAuthentication == [.apiKey, .bearerToken])
    }

    func json(_ parameters: Designer.AutoDesignParameters) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(AutoDesignParametersDTO(parameters))) as? [String: Any])
    }

    @Test
    func minimalBodyHasOnlyTheSite() throws {
        let body = try json(exampleAutoDesign)

        #expect(Set(body.keys) == ["site"])
        #expect(Set(try #require(body["site"] as? [String: Any]).keys) == ["siteName", "latitude", "longitude"])
    }

    /// `phase` and `pricePerWatt` are wrapped in the spec's single-field objects.
    @Test
    func fullBodyUsesTheSpecShape() throws {
        let body = try json(fullAutoDesign)
        let placement = try #require(body["pvPlacement"] as? [String: Any])

        #expect((body["site"] as? [String: Any])?["sector"] as? String == "RESIDENTIAL")
        #expect((body["consumption"] as? [String: Any])?["consumptionProfileId"] as? String == "double_peak")
        #expect(placement["moduleModelId"] as? Int == 19676)
        #expect(placement["racking"] as? String == "TILTED")
        #expect(placement["orientation"] as? String == "LANDSCAPE")
        #expect(placement["setbackProfileId"] as? Int == 3)
        #expect(body["electricalDesign"] as? [String: Int] == ["phase": 3])
        #expect(body["financials"] as? [String: Double] == ["pricePerW": 1.2])
    }

    @Test
    func mapsTheResponses() throws {
        let request = try JSONDecoder().decode(AutoDesignResponseDTO.self, from: Data(#"{"requestId":"req-1","siteId":42}"#.utf8)).entity
        let status = try JSONDecoder().decode(AutoDesignStatusResponseDTO.self, from: Data(
            #"{"siteId":42,"executedSteps":{"MODELING":1,"PV_PLACEMENT":0.5},"errorCode":"MISSING_PV_MODEL_ID"}"#.utf8)).entity

        #expect(request == Designer.AutoDesignRequest(requestID: "req-1", siteID: 42))
        #expect(status == Designer.AutoDesignStatus(siteID: 42, executedSteps: ["MODELING": 1, "PV_PLACEMENT": 0.5], errorCode: .missingPvModelID))
    }

    /// An error code added on the server is kept, not a decoding error.
    @Test
    func keepsAnUnknownErrorCode() throws {
        let dto = try JSONDecoder().decode(AutoDesignStatusResponseDTO.self, from: Data(#"{"siteId":42,"executedSteps":{},"errorCode":"OOPS"}"#.utf8))

        #expect(try dto.entity.errorCode == .unknown("OOPS"))
    }

    @Test(arguments: [
        { (p: inout Designer.AutoDesignParameters) in p.site.siteName = "" },
        { p in p.site.latitude = 90.5 },
        { p in p.site.longitude = -180.5 },
        { p in p.site.gridID = "" },
    ] as [@Sendable (inout Designer.AutoDesignParameters) -> Void])
    func invalidParametersAreRejected(_ change: @Sendable (inout Designer.AutoDesignParameters) -> Void) {
        var parameters = exampleAutoDesign
        change(&parameters)

        #expect(throws: SolarEdgeError.self) { try parameters.validate() }
    }

    /// Fails the test if a request is sent.
    struct NoRequestTransport: HTTPTransport {
        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            Issue.record("No request expected, got \(request.url!)")
            throw SolarEdgeError.invalidResponse
        }
    }

    @Test
    func invalidInputIsRejectedBeforeSending() async {
        let service = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL,
                                              transport: NoRequestTransport()).autoDesign

        await #expect(throws: SolarEdgeError.self) { try await service.start(.init(site: .init(siteName: " ", latitude: 0, longitude: 0))) }
        await #expect(throws: SolarEdgeError.self) { try await service.status(of: "") }
    }
}

/// Sends real requests to the Stoplight mock of the Designer API, which
/// checks the bodies against the spec. The spec has no examples, so the mock
/// generates placeholder values. Needs network access.
@Suite(.tags(.mockServer))
struct AutoDesignMockTests {

    let service = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL).autoDesign

    @Test
    func start() async throws {
        #expect(try await service.start(exampleAutoDesign).requestID == "string")
        _ = try await service.start(fullAutoDesign)
    }

    /// The mock always sends an error code, here `UNKNOWN_ERROR`.
    @Test
    func status() async throws {
        let status = try await service.status(of: "req 1")

        #expect(status.errorCode == .unknownError)
        #expect(status.executedSteps.count == 2)
    }

    @Test
    func acceptsADesignerKeyAsBearerToken() async throws {
        let service = SolarEdgeDesignerClient(credentials: .bearerToken(StaticTokenProvider(token: "123")),
                                              baseURL: DesignerMockServer.baseURL).autoDesign

        _ = try await service.start(exampleAutoDesign)
    }
}
