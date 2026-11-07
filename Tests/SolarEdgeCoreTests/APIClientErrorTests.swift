import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeCore

/// The mapping from HTTP status to `SolarEdgeError`, without a network.
struct APIClientErrorTests {

    struct StubTransport: HTTPTransport {
        let statusCode: Int
        let body: String
        var headers: [String: String] = [:]

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: headers)!
            return (Data(body.utf8), response)
        }
    }

    struct Empty: Decodable, Sendable {}

    struct TestEndpoint: Endpoint {
        typealias Response = Empty
        var path: String { "test" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey] }
    }

    func send(status: Int, body: String = "", headers: [String: String] = [:]) async -> SolarEdgeError? {
        let client = APIClient(baseURL: URL(string: "https://example.invalid")!,
                               credentials: .apiKey("123"),
                               transport: StubTransport(statusCode: status, body: body, headers: headers))
        do {
            _ = try await client.send(TestEndpoint())
            return nil
        } catch {
            return error as? SolarEdgeError
        }
    }

    @Test
    func unauthorized() async {
        guard case .unauthorized(let details) = await send(status: 401, body: #"{"error":"invalid_request","error_description":"The access token is missing"}"#) else {
            Issue.record("Expected .unauthorized"); return
        }
        #expect(details?.code == "invalid_request")
    }

    @Test
    func forbiddenAndNotFound() async {
        guard case .forbidden(let forbidden) = await send(status: 403, body: #"{"detail":"No access to site"}"#) else {
            Issue.record("Expected .forbidden"); return
        }
        guard case .notFound(let notFound) = await send(status: 404) else {
            Issue.record("Expected .notFound"); return
        }
        #expect(forbidden?.message == "No access to site")
        #expect(notFound == nil)
    }

    @Test
    func rateLimitedKeepsRetryAfterAndDetails() async {
        let error = await send(status: 429, body: #"{"message":"API rate limit exceeded","request_id":"r-1"}"#, headers: ["Retry-After": "120"])
        guard case .rateLimited(let retryAfter, let details, let limits) = error else {
            Issue.record("Expected .rateLimited"); return
        }
        #expect(limits == nil)
        #expect(retryAfter == 120)
        #expect(details?.requestID == "r-1")
        #expect(error?.localizedDescription == "API rate limit exceeded Retry after 120 s.")
    }

    @Test
    func otherStatusesBecomeHTTP() async {
        guard case .http(let status, let details) = await send(status: 400, body: #"{"errors":{"page":"must be >= 1"}}"#) else {
            Issue.record("Expected .http"); return
        }
        #expect(status == 400)
        #expect(details?.fieldErrors == ["page": "must be >= 1"])
    }

    /// Without `problem+json` in `Accept`, the mock answers 400, 403 and 404
    /// with a 200 instead; a real server might reject the request.
    @Test
    func acceptsProblemJSON() async throws {
        let recorder = RecordingTransport()
        let client = APIClient(baseURL: URL(string: "https://example.invalid")!, credentials: .apiKey("123"), transport: recorder)

        _ = try await client.send(TestEndpoint())

        let accept = try #require(await recorder.lastRequest?.value(forHTTPHeaderField: "Accept"))
        #expect(accept.contains("application/json"))
        #expect(accept.contains("application/problem+json"))
    }

    actor RecordingTransport: HTTPTransport {
        var lastRequest: URLRequest?

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            lastRequest = request
            return (Data("{}".utf8), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
    }

    @Test
    func fallbackMessagesWithoutBody() async {
        #expect(await send(status: 401)?.localizedDescription == "The credentials were rejected (HTTP 401).")
        #expect(await send(status: 500)?.localizedDescription == "Unexpected HTTP status 500.")
    }
}
