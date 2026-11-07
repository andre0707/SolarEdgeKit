import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeCore

/// A `200` with or without a body, for endpoints whose response is optional.
struct EmptyBodyTests {

    struct Body: Decodable, Sendable, Equatable {
        let status: String
    }

    struct OptionalBodyEndpoint: Endpoint {
        typealias Response = Body?
        var method: HTTPMethod { .post }
        var path: String { "start" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey] }
    }

    struct RequiredBodyEndpoint: Endpoint {
        typealias Response = Body
        var path: String { "read" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey] }
    }

    struct StubTransport: HTTPTransport {
        let body: String

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            (Data(body.utf8), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
    }

    func client(_ body: String) -> APIClient {
        APIClient(baseURL: URL(string: "https://example.invalid")!, credentials: .apiKey("123"), transport: StubTransport(body: body))
    }

    @Test(arguments: ["", " \n", "null"])
    func optionalResponseAcceptsNoBody(_ body: String) async throws {
        #expect(try await client(body).send(OptionalBodyEndpoint()) == nil)
    }

    @Test
    func optionalResponseDecodesABody() async throws {
        #expect(try await client(#"{"status":"OK"}"#).send(OptionalBodyEndpoint()) == Body(status: "OK"))
    }

    /// Only optional responses accept an empty body.
    @Test
    func requiredResponseRejectsNoBody() async {
        await #expect(throws: SolarEdgeError.self) {
            try await client("").send(RequiredBodyEndpoint())
        }
    }

    /// A body that does not match is still an error, not `nil`.
    @Test
    func optionalResponseRejectsAWrongBody() async {
        await #expect(throws: SolarEdgeError.self) {
            try await client(#"{"other":1}"#).send(OptionalBodyEndpoint())
        }
    }
}
