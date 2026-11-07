import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeCore

/// Errors from token providers and transports become `SolarEdgeError`,
/// except cancellation and errors that already are one.
struct ErrorWrappingTests {

    struct SomeError: Error, Equatable {}

    /// Throws the given error from `send`, or answers 200.
    struct ThrowingTransport: HTTPTransport {
        let error: (any Error & Sendable)?

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            if let error { throw error }
            return (Data("{}".utf8), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
    }

    /// Throws the given error from `accessToken()`.
    struct ThrowingProvider: AccessTokenProvider {
        let error: any Error & Sendable
        func accessToken() async throws -> String { throw error }
    }

    struct Empty: Decodable, Sendable {}

    struct GetEndpoint: Endpoint {
        typealias Response = Empty
        var path: String { "items" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
    }

    func send(_ transport: ThrowingTransport, _ credentials: SolarEdgeCredentials = .apiKey("123")) async throws {
        _ = try await APIClient(baseURL: URL(string: "https://example.invalid")!, credentials: credentials, transport: transport)
            .send(GetEndpoint())
    }

    // MARK: - Token provider

    @Test
    func aProviderErrorBecomesAuthentication() async throws {
        await #expect {
            try await send(ThrowingTransport(error: nil), .bearerToken(ThrowingProvider(error: SomeError())))
        } throws: { error in
            guard case SolarEdgeError.authentication(let underlying) = error else { return false }
            return underlying is SomeError
        }
    }

    @Test
    func aProviderCancellationStaysACancellation() async throws {
        await #expect(throws: CancellationError.self) {
            try await send(ThrowingTransport(error: nil), .bearerToken(ThrowingProvider(error: CancellationError())))
        }
    }

    @Test
    func aSolarEdgeErrorFromTheProviderPassesThrough() async throws {
        await #expect {
            try await send(ThrowingTransport(error: nil), .bearerToken(ThrowingProvider(error: SolarEdgeError.invalidRequest("no login"))))
        } throws: { error in
            guard case SolarEdgeError.invalidRequest("no login") = error else { return false }
            return true
        }
    }

    // MARK: - Transport

    @Test
    func aTransportErrorBecomesTransport() async throws {
        await #expect {
            try await send(ThrowingTransport(error: SomeError()))
        } throws: { error in
            guard case SolarEdgeError.transport(let underlying) = error else { return false }
            return underlying is SomeError
        }
    }

    @Test
    func aURLErrorStaysNetwork() async throws {
        await #expect {
            try await send(ThrowingTransport(error: URLError(.notConnectedToInternet)))
        } throws: { error in
            guard case SolarEdgeError.network(let urlError) = error else { return false }
            return urlError.code == .notConnectedToInternet
        }
    }

    @Test(arguments: [URLError(.cancelled) as any Error & Sendable, CancellationError()])
    func aCancelledTransportThrowsCancellation(_ thrown: any Error & Sendable) async throws {
        await #expect(throws: CancellationError.self) {
            try await send(ThrowingTransport(error: thrown))
        }
    }

    @Test
    func aSolarEdgeErrorFromTheTransportPassesThrough() async throws {
        await #expect {
            try await send(ThrowingTransport(error: SolarEdgeError.invalidResponse))
        } throws: { error in
            guard case SolarEdgeError.invalidResponse = error else { return false }
            return true
        }
    }
}
