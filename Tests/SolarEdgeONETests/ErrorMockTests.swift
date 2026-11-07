import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SolarEdgeONE

/// Error responses from the Stoplight mock server. Needs network access.
///
/// The mock answers with a given status when asked with `Prefer: code=…`,
/// using the spec's error examples (gateway errors for 401 and 429,
/// `problem+json` with placeholder strings otherwise).
@Suite(.tags(.mockServer))
struct ErrorMockTests {

    /// Forwards to `URLSession` and asks the mock for a specific status.
    struct PreferStatusTransport: HTTPTransport {
        let statusCode: Int

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            var request = request
            request.setValue("code=\(statusCode)", forHTTPHeaderField: "Prefer")
            return try await URLSessionTransport().send(request)
        }
    }

    func error(for statusCode: Int) async -> SolarEdgeError? {
        let client = SolarEdgeONEClient(credentials: .apiKey("123"),
                                        baseURL: MockServer.baseURL,
                                        transport: PreferStatusTransport(statusCode: statusCode))
        do {
            _ = try await client.sites.details(for: 93082)
            return nil
        } catch {
            return error as? SolarEdgeError
        }
    }

    @Test
    func badRequestCarriesProblemDetails() async {
        guard case .http(400, let details) = await error(for: 400) else {
            Issue.record("Expected .http(400)"); return
        }
        #expect(details?.requestID == "string")
        #expect(details?.fieldErrors == ["property1": "string", "property2": "string"])
    }

    @Test
    func unauthorizedCarriesGatewayDetails() async {
        guard case .unauthorized(let details) = await error(for: 401) else {
            Issue.record("Expected .unauthorized"); return
        }
        #expect(details?.message == "The access token is missing")
        #expect(details?.code == "invalid_request")
        #expect(details?.requestID == "a214540d37085042a568820b95b1357f")
    }

    @Test
    func forbiddenAndNotFound() async {
        guard case .forbidden(let forbidden) = await error(for: 403) else {
            Issue.record("Expected .forbidden"); return
        }
        guard case .notFound(let notFound) = await error(for: 404) else {
            Issue.record("Expected .notFound"); return
        }
        #expect(forbidden?.message == "string")
        #expect(notFound?.message == "string")
    }

    @Test
    func rateLimitedReadsRetryAfterAndBody() async {
        guard case .rateLimited(let retryAfter, let details, let limits) = await error(for: 429) else {
            Issue.record("Expected .rateLimited"); return
        }
        // The mock sends all six x-ratelimit headers, each 0.
        let zero = SolarEdgeError.RateLimit.Window(limit: 0, remaining: 0)
        #expect(limits == SolarEdgeError.RateLimit(perMinute: zero, perMonth: zero, perSecond: zero))
        #expect(limits?.isMonthlyQuotaExhausted == true)
        #expect(retryAfter == 0)
        #expect(details?.requestID == "a214540d37085042a568820b95b1357f")
    }
}
