import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeONE

/// The OAuth endpoints and the token provider, against a local fake server.
struct OAuthTests {

    /// Answers `oauth2/token` with numbered pairs (`access-1`/`refresh-1`, …)
    /// or a queued error, `oauth2/revoke-token` with 200, and API calls with
    /// 200 only for the token `access-<validAccess>`.
    actor FakeServer: HTTPTransport {
        var requests: [URLRequest] = []
        var tokenErrors: [(status: Int, body: String)] = []
        var issued = 0
        var validAccess = 1
        var tokenDelay: Duration = .zero

        func failNextToken(status: Int, body: String) { tokenErrors.append((status, body)) }
        func accept(access number: Int) { validAccess = number }
        func delayTokens(by duration: Duration) { tokenDelay = duration }

        var tokenRequests: [URLRequest] { requests.filter { $0.url!.path.hasSuffix("oauth2/token") } }
        var apiRequests: [URLRequest] { requests.filter { !$0.url!.path.contains("oauth2") } }

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            requests.append(request)
            let path = request.url!.path
            if path.hasSuffix("oauth2/token") {
                if tokenDelay > .zero { try await Task.sleep(for: tokenDelay) }
                if !tokenErrors.isEmpty {
                    let error = tokenErrors.removeFirst()
                    return response(request, error.status, error.body)
                }
                issued += 1
                return response(request, 200, """
                    {"access_token": "access-\(issued)", "token_type": "Bearer", "expires_in": 7200, "refresh_token": "refresh-\(issued)"}
                    """)
            }
            if path.hasSuffix("oauth2/revoke-token") {
                return response(request, 200, "")
            }
            let valid = request.value(forHTTPHeaderField: "Authorization") == "Bearer access-\(validAccess)"
            return response(request, valid ? 200 : 401, "{}")
        }

        private func response(_ request: URLRequest, _ status: Int, _ body: String) -> (Data, HTTPURLResponse) {
            (Data(body.utf8), HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!)
        }
    }

    /// Records the pairs passed to `onRefresh`.
    actor SavedTokens {
        var pairs: [Monitoring.OAuthTokens] = []
        func save(_ tokens: Monitoring.OAuthTokens) { pairs.append(tokens) }
    }

    static let start = Date(timeIntervalSince1970: 1_800_000_000)
    static let baseURL = URL(string: "https://example.invalid/v2")!

    func oauth(_ server: FakeServer, now: Date = start) -> Monitoring.OAuthClient {
        Monitoring.OAuthClient(clientID: "client", clientSecret: "secret", baseURL: Self.baseURL, transport: server, now: { now })
    }

    func provider(
        _ server: FakeServer,
        expiresIn seconds: TimeInterval,
        saved: SavedTokens = SavedTokens()
    ) -> Monitoring.OAuthTokenProvider {
        Monitoring.OAuthTokenProvider(
            tokens: .init(accessToken: "access-0", refreshToken: "refresh-0", expiresAt: Self.start.addingTimeInterval(seconds)),
            oauth: oauth(server),
            refreshMargin: 300,
            now: { Self.start },
            onRefresh: { await saved.save($0) }
        )
    }

    func json(_ request: URLRequest) throws -> [String: String] {
        try JSONDecoder().decode([String: String].self, from: try #require(request.httpBody))
    }

    // MARK: - Authorization URL

    @Test
    func authorizationURL() {
        #expect(Monitoring.OAuthClient.authorizationURL(clientID: "abc").absoluteString
                == "https://connect.solaredge.com/authorize?client_id=abc")
        #expect(Monitoring.OAuthClient.authorizationURL(clientID: "abc", externalID: "user 7").absoluteString
                == "https://connect.solaredge.com/authorize?client_id=abc&external_id=user%207")
    }

    // MARK: - OAuthClient

    @Test
    func exchangeSendsTheCodeAndReturnsThePair() async throws {
        let server = FakeServer()

        let tokens = try await oauth(server).exchange(code: "the-code")

        #expect(tokens == .init(accessToken: "access-1", refreshToken: "refresh-1", expiresAt: Self.start.addingTimeInterval(7200)))
        let request = try #require(await server.requests.first)
        #expect(request.url?.absoluteString == "https://example.invalid/v2/oauth2/token")
        #expect(request.httpMethod == HTTPMethod.post.rawValue)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(try json(request) == [
            "grant_type": "authorization_code", "code": "the-code", "client_id": "client", "client_secret": "secret",
        ])
    }

    @Test
    func refreshSendsTheRefreshToken() async throws {
        let server = FakeServer()

        _ = try await oauth(server).refresh("refresh-0")

        #expect(try json(try #require(await server.requests.first)) == [
            "grant_type": "refresh_token", "refresh_token": "refresh-0", "client_id": "client", "client_secret": "secret",
        ])
    }

    @Test
    func revokeSendsOnlyTheToken() async throws {
        let server = FakeServer()

        try await oauth(server).revoke("refresh-0")

        let request = try #require(await server.requests.first)
        #expect(request.url?.absoluteString == "https://example.invalid/v2/oauth2/revoke-token")
        #expect(try json(request) == ["token": "refresh-0"])
    }

    @Test
    func anOAuthErrorResponseIsThrownAsOAuthError() async throws {
        let server = FakeServer()
        await server.failNextToken(status: 400, body: #"{"error": "invalid_request", "error_description": "Invalid code"}"#)

        await #expect(throws: Monitoring.OAuthError(statusCode: 400, code: "invalid_request", message: "Invalid code")) {
            try await oauth(server).exchange(code: "used")
        }
    }

    @Test
    func anErrorWithoutAnOAuthBodyKeepsTheStatus() async throws {
        let server = FakeServer()
        await server.failNextToken(status: 502, body: "<html>Bad Gateway</html>")

        await #expect(throws: Monitoring.OAuthError(statusCode: 502, code: nil, message: nil)) {
            try await oauth(server).exchange(code: "code")
        }
    }

    // MARK: - OAuthTokenProvider

    @Test
    func aValidTokenIsReturnedWithoutARequest() async throws {
        let server = FakeServer()
        let provider = provider(server, expiresIn: 3600)

        #expect(try await provider.accessToken() == "access-0")
        #expect(await server.requests.isEmpty)
    }

    @Test
    func aTokenInsideTheMarginIsRefreshedAndSaved() async throws {
        let server = FakeServer()
        let saved = SavedTokens()
        let provider = provider(server, expiresIn: 200, saved: saved)

        #expect(try await provider.accessToken() == "access-1")
        #expect(try json(try #require(await server.tokenRequests.first))["refresh_token"] == "refresh-0")
        #expect(await saved.pairs.map(\.refreshToken) == ["refresh-1"])
        #expect(await provider.tokens.refreshToken == "refresh-1")
        // The new pair is used from now on.
        #expect(try await provider.accessToken() == "access-1")
        #expect(await server.tokenRequests.count == 1)
    }

    @Test
    func concurrentCallersShareOneRefresh() async throws {
        let server = FakeServer()
        await server.delayTokens(by: .milliseconds(50))
        let provider = provider(server, expiresIn: 0)

        let tokens = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<5 { group.addTask { try await provider.accessToken() } }
            return try await group.reduce(into: []) { $0.append($1) }
        }

        #expect(tokens == Array(repeating: "access-1", count: 5))
        #expect(await server.tokenRequests.count == 1)
    }

    @Test
    func invalidatingTheCurrentTokenForcesARefresh() async throws {
        let server = FakeServer()
        let provider = provider(server, expiresIn: 3600)

        await provider.invalidate("access-0")

        #expect(try await provider.accessToken() == "access-1")
    }

    @Test
    func invalidatingAnOlderTokenChangesNothing() async throws {
        let server = FakeServer()
        let provider = provider(server, expiresIn: 3600)

        await provider.invalidate("access-old")

        #expect(try await provider.accessToken() == "access-0")
        #expect(await server.requests.isEmpty)
    }

    @Test
    func aFailedRefreshInsideTheMarginKeepsTheOldToken() async throws {
        let server = FakeServer()
        await server.failNextToken(status: 503, body: "")
        let saved = SavedTokens()
        let provider = provider(server, expiresIn: 200, saved: saved)

        #expect(try await provider.accessToken() == "access-0")
        #expect(await saved.pairs.isEmpty)
        // The next call tries again.
        #expect(try await provider.accessToken() == "access-1")
    }

    @Test
    func aFailedRefreshAfterExpiryIsThrown() async throws {
        let server = FakeServer()
        await server.failNextToken(status: 400, body: #"{"error": "invalid_grant"}"#)
        let provider = provider(server, expiresIn: -1)

        await #expect(throws: Monitoring.OAuthError(statusCode: 400, code: "invalid_grant", message: nil)) {
            try await provider.accessToken()
        }
    }

    @Test
    func revokeRevokesTheRefreshToken() async throws {
        let server = FakeServer()
        let provider = provider(server, expiresIn: 3600)

        try await provider.revoke()

        #expect(try json(try #require(await server.requests.first)) == ["token": "refresh-0"])
    }

    // MARK: - With the client

    @Test
    func theClientRefreshesAfterA401AndRepeatsTheRequest() async throws {
        let server = FakeServer()  // accepts only access-1
        let provider = provider(server, expiresIn: 3600)
        let client = SolarEdgeONEClient(credentials: .bearerToken(provider), baseURL: Self.baseURL, transport: server)

        _ = try? await client.sites.overview(for: 1)  // "{}" may not decode; only the headers matter

        #expect(await server.apiRequests.map { $0.value(forHTTPHeaderField: "Authorization") } == ["Bearer access-0", "Bearer access-1"])
        #expect(await server.tokenRequests.count == 1)
    }

    @Test
    func aRejectedRefreshArrivesAsAnAuthenticationError() async throws {
        let server = FakeServer()
        await server.failNextToken(status: 400, body: #"{"error": "invalid_grant"}"#)
        let provider = provider(server, expiresIn: -1)
        let client = SolarEdgeONEClient(credentials: .bearerToken(provider), baseURL: Self.baseURL, transport: server)

        await #expect {
            try await client.sites.overview(for: 1)
        } throws: { error in
            guard case SolarEdgeError.authentication(let underlying) = error else { return false }
            return (underlying as? Monitoring.OAuthError)?.code == "invalid_grant"
        }
        #expect(await server.apiRequests.isEmpty)
    }
}
