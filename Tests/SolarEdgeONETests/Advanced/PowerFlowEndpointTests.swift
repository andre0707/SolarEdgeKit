import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeONE
import SolarEdgeCore

struct PowerFlowEndpointTests {

    @Test
    func readAndStartUseTheSamePathWithDifferentMethods() {
        let read = SitePowerFlowEndpoint(siteID: 93082)
        let start = StartLivePowerFlowEndpoint(siteID: 93082)

        #expect(read.path == "sites/93082/power-flow")
        #expect(read.method == .get)
        #expect(start.path == "sites/93082/power-flow")
        #expect(start.method == .post)
        #expect(start.queryItems.isEmpty)
        #expect(start.supportedAuthentication == [.apiKey, .bearerToken])
    }

    /// Forwards nothing; answers `200` with the given body.
    struct StubTransport: HTTPTransport {
        let body: String

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            #expect(request.httpMethod == HTTPMethod.post.rawValue)
            return (Data(body.utf8), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
    }

    /// The spec says the `200` has no body.
    @Test
    func startWithoutBodyReturnsNil() async throws {
        let client = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.advancedBaseURL, transport: StubTransport(body: ""))

        #expect(try await client.advanced.startLivePowerFlow(for: 93082) == nil)
    }

    /// ... but also describes one.
    @Test
    func startWithBodyReturnsIt() async throws {
        let client = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.advancedBaseURL,
                                        transport: StubTransport(body: #"{"status":"ACTIVATED","refreshRate":3}"#))

        #expect(try await client.advanced.startLivePowerFlow(for: 93082) == Monitoring.LivePowerFlowStart(status: "ACTIVATED", refreshRate: 3))
    }
}
