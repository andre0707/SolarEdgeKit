import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeCore

/// Request bodies, the `Accept` header and raw responses.
struct RequestTests {

    actor RecordingTransport: HTTPTransport {
        var lastRequest: URLRequest?
        let statusCode: Int
        let responseBody: Data

        init(statusCode: Int = 200, responseBody: Data = Data("{}".utf8)) {
            self.statusCode = statusCode
            self.responseBody = responseBody
        }

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            lastRequest = request
            return (responseBody, HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!)
        }
    }

    struct Empty: Decodable, Sendable {}
    struct Payload: Codable, Sendable, Equatable {
        let name: String
        let count: Int
    }

    struct PostEndpoint: Endpoint {
        typealias Response = Empty
        var method: HTTPMethod { .post }
        var path: String { "items" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
        var body: (any Encodable & Sendable)? { Payload(name: "Panel", count: 3) }
    }

    struct GetEndpoint: Endpoint {
        typealias Response = Empty
        var path: String { "items" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey] }
    }

    struct ImageEndpoint: Endpoint {
        typealias Response = Data
        var path: String { "image" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey] }
        var accept: String { "image/png, application/json, application/problem+json" }
    }

    func client(_ transport: RecordingTransport, credentials: SolarEdgeCredentials = .apiKey("123")) -> APIClient {
        APIClient(baseURL: URL(string: "https://example.invalid")!, credentials: credentials, transport: transport)
    }

    @Test
    func bodyIsSentAsJSON() async throws {
        let transport = RecordingTransport()
        _ = try await client(transport).send(PostEndpoint())

        let request = try #require(await transport.lastRequest)
        #expect(request.httpMethod == HTTPMethod.post.rawValue)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        let body = try #require(request.httpBody)
        #expect(try JSONDecoder().decode(Payload.self, from: body) == Payload(name: "Panel", count: 3))
    }

    @Test
    func noBodyMeansNoContentType() async throws {
        let transport = RecordingTransport()
        _ = try await client(transport).send(GetEndpoint())

        let request = try #require(await transport.lastRequest)
        #expect(request.httpBody == nil)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == nil)
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json, application/problem+json")
    }

    @Test
    func rawResponsesAreReturnedAsTheyAre() async throws {
        let png = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        let transport = RecordingTransport(responseBody: png)

        #expect(try await client(transport).send(ImageEndpoint()) == png)
        #expect(await transport.lastRequest?.value(forHTTPHeaderField: "Accept") == "image/png, application/json, application/problem+json")
    }

    /// A raw response type does not bypass error handling.
    @Test
    func rawResponsesStillReportErrors() async {
        let transport = RecordingTransport(statusCode: 404, responseBody: Data(#"{"message":"Image not found"}"#.utf8))

        await #expect(throws: SolarEdgeError.self) {
            try await client(transport).send(ImageEndpoint())
        }
    }

    @Test
    func staticTokenIsSentAsBearer() async throws {
        let transport = RecordingTransport()
        _ = try await client(transport, credentials: .bearerToken(StaticTokenProvider(token: "designer-key"))).send(PostEndpoint())

        #expect(await transport.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer designer-key")
    }
}
