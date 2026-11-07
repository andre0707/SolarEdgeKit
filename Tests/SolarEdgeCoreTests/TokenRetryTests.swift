import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeCore

/// A `401` with a bearer token: invalidate, fetch a new token, retry once.
struct TokenRetryTests {

    /// Accepts only the token `valid`, and records every request.
    actor TokenCheckingTransport: HTTPTransport {
        var requests: [URLRequest] = []

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            requests.append(request)
            let status = request.value(forHTTPHeaderField: "Authorization") == "Bearer valid" ? 200 : 401
            return (Data("{}".utf8), HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!)
        }
    }

    /// Hands out the tokens in order; `invalidate` moves on to the next one.
    actor RotatingProvider: AccessTokenProvider {
        let tokens: [String]
        var index = 0
        var invalidated: [String] = []

        init(_ tokens: [String]) { self.tokens = tokens }

        func accessToken() async throws -> String { tokens[index] }

        func invalidate(_ token: String) async {
            invalidated.append(token)
            if token == tokens[index], index + 1 < tokens.count { index += 1 }
        }
    }

    struct Empty: Decodable, Sendable {}

    struct PostEndpoint: Endpoint {
        typealias Response = Empty
        var method: HTTPMethod { .post }
        var path: String { "items" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
        var body: (any Encodable & Sendable)? { ["name": "Panel"] }
    }

    func client(_ transport: TokenCheckingTransport, _ credentials: SolarEdgeCredentials) -> APIClient {
        APIClient(baseURL: URL(string: "https://example.invalid")!, credentials: credentials, transport: transport)
    }

    @Test
    func aRejectedTokenIsReplacedAndTheRequestRepeatedOnce() async throws {
        let transport = TokenCheckingTransport()
        let provider = RotatingProvider(["expired", "valid"])

        _ = try await client(transport, .bearerToken(provider)).send(PostEndpoint())

        #expect(await provider.invalidated == ["expired"])
        let requests = await transport.requests
        #expect(requests.map { $0.value(forHTTPHeaderField: "Authorization") } == ["Bearer expired", "Bearer valid"])
        // The repeated request is the same request, body included.
        #expect(requests[1].httpMethod == HTTPMethod.post.rawValue)
        #expect(requests[1].httpBody == requests[0].httpBody)
    }

    @Test
    func aSecondRejectionIsThrownWithoutAThirdAttempt() async throws {
        let transport = TokenCheckingTransport()
        let provider = RotatingProvider(["expired", "revoked", "valid"])

        await #expect {
            try await client(transport, .bearerToken(provider)).send(PostEndpoint())
        } throws: { error in
            guard case SolarEdgeError.unauthorized = error else { return false }
            return true
        }
        #expect(await transport.requests.count == 2)
        #expect(await provider.invalidated == ["expired"])
    }

    @Test
    func theSameTokenAgainIsNotRetried() async throws {
        let transport = TokenCheckingTransport()
        let provider = RotatingProvider(["expired"])

        await #expect(throws: SolarEdgeError.self) {
            try await client(transport, .bearerToken(provider)).send(PostEndpoint())
        }
        #expect(await transport.requests.count == 1)
        #expect(await provider.invalidated == ["expired"])
    }

    @Test
    func aStaticTokenIsNotRetried() async throws {
        let transport = TokenCheckingTransport()

        await #expect(throws: SolarEdgeError.self) {
            try await client(transport, .bearerToken(StaticTokenProvider(token: "123"))).send(PostEndpoint())
        }
        #expect(await transport.requests.count == 1)
    }

    @Test
    func anAPIKeyIsNotRetried() async throws {
        let transport = TokenCheckingTransport()

        await #expect(throws: SolarEdgeError.self) {
            try await client(transport, .apiKey("123")).send(PostEndpoint())
        }
        #expect(await transport.requests.count == 1)
    }
}
