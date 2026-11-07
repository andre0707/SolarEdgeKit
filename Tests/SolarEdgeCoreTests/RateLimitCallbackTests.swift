import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeCore

/// `onRateLimit` is called for every response with `x-ratelimit-*` headers.
struct RateLimitCallbackTests {

    /// Answers every request with the given status and headers.
    struct FixedTransport: HTTPTransport {
        let statusCode: Int
        let headers: [String: String]

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            (Data("{}".utf8), HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: headers)!)
        }
    }

    /// Collects what the callback received. (`Mutex` needs macOS 15; the package supports 13.)
    final class Recorder: @unchecked Sendable {
        private let lock = NSLock()
        private var storage: [SolarEdgeError.RateLimit] = []
        var received: [SolarEdgeError.RateLimit] { lock.withLock { storage } }
        func record(_ limits: SolarEdgeError.RateLimit) { lock.withLock { storage.append(limits) } }
    }

    struct Empty: Decodable, Sendable {}

    struct GetEndpoint: Endpoint {
        typealias Response = Empty
        var path: String { "items" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey] }
    }

    static let minuteHeaders = ["x-ratelimit-limit-minute": "300", "x-ratelimit-remaining-minute": "299"]

    func client(_ transport: FixedTransport, _ recorder: Recorder) -> APIClient {
        APIClient(baseURL: URL(string: "https://example.invalid")!, credentials: .apiKey("123"),
                  transport: transport, onRateLimit: { recorder.record($0) })
    }

    @Test
    func aSuccessfulResponseReportsItsLimits() async throws {
        let recorder = Recorder()
        _ = try await client(FixedTransport(statusCode: 200, headers: Self.minuteHeaders), recorder).send(GetEndpoint())

        #expect(recorder.received == [SolarEdgeError.RateLimit(perMinute: .init(limit: 300, remaining: 299), perMonth: nil, perSecond: nil)])
    }

    @Test
    func a429ReportsItsLimitsAndStillThrows() async throws {
        let recorder = Recorder()
        await #expect(throws: SolarEdgeError.self) {
            try await client(FixedTransport(statusCode: 429, headers: Self.minuteHeaders), recorder).send(GetEndpoint())
        }
        #expect(recorder.received.count == 1)
    }

    @Test
    func aResponseWithoutHeadersIsNotReported() async throws {
        let recorder = Recorder()
        _ = try await client(FixedTransport(statusCode: 200, headers: [:]), recorder).send(GetEndpoint())

        #expect(recorder.received.isEmpty)
    }
}
