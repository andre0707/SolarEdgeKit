//
//  OAuthClient.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 05.11.26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SolarEdgeCore

extension Monitoring {
    /// The OAuth 2.0 endpoints for Site Access: exchanging an authorization
    /// code, refreshing tokens and revoking them.
    ///
    /// Holds the client secret, so use it only where the secret is safe: on
    /// your backend, or in a tool for your own sites. Never ship the secret
    /// inside an app given to others.
    ///
    /// ```swift
    /// let oauth = Monitoring.OAuthClient(clientID: clientID, clientSecret: clientSecret)
    /// // 1. Send the homeowner to Monitoring.OAuthClient.authorizationURL(clientID:).
    /// // 2. Your redirect URL receives `code` and `site_id`.
    /// let tokens = try await oauth.exchange(code: code)
    /// ```
    public struct OAuthClient: Sendable {
        /// The SolarEdge Connect page where the homeowner signs in and approves.
        public static let authorizeURL = URL(string: "https://connect.solaredge.com/authorize")!

        public let clientID: String
        private let clientSecret: String
        private let baseURL: URL
        private let transport: any HTTPTransport
        private let now: @Sendable () -> Date

        /// - Parameters:
        ///   - clientID: Your application's client ID.
        ///   - clientSecret: Your application's client secret. Load it from
        ///     secure storage; never put it in source code.
        ///   - baseURL: The API server; the endpoints are `oauth2/token` and
        ///     `oauth2/revoke-token` below it.
        ///   - transport: Sends the requests.
        public init(
            clientID: String,
            clientSecret: String,
            baseURL: URL = SolarEdgeONEClient.productionURL,
            transport: any HTTPTransport = URLSessionTransport()
        ) {
            self.init(clientID: clientID, clientSecret: clientSecret, baseURL: baseURL, transport: transport, now: { Date() })
        }

        init(
            clientID: String,
            clientSecret: String,
            baseURL: URL,
            transport: any HTTPTransport,
            now: @escaping @Sendable () -> Date
        ) {
            self.clientID = clientID
            self.clientSecret = clientSecret
            self.baseURL = baseURL
            self.transport = transport
            self.now = now
        }

        /// Where to send the homeowner to connect a site (step 1).
        ///
        /// Each approval connects one site; the callback to your redirect URL
        /// carries `code`, `site_id` and, if given here, `external_id`.
        ///
        /// - Parameter externalID: Your own identifier for the user, returned
        ///   in the callback so you can match the site to your customer.
        public static func authorizationURL(clientID: String, externalID: String? = nil) -> URL {
            var components = URLComponents(url: authorizeURL, resolvingAgainstBaseURL: false)!
            components.queryItems = [URLQueryItem(name: "client_id", value: clientID)]
            if let externalID {
                components.queryItems?.append(URLQueryItem(name: "external_id", value: externalID))
            }
            return components.url!
        }

        /// Exchanges the one-time authorization code from the callback for
        /// the site's first token pair (step 4).
        ///
        /// - Throws: ``OAuthError``, e.g. `invalid_request` if the code was
        ///   already used or has expired; or a ``SolarEdgeError`` for network
        ///   and decoding failures.
        public func exchange(code: String) async throws -> OAuthTokens {
            try await requestTokens([
                "grant_type": "authorization_code",
                "code": code,
                "client_id": clientID,
                "client_secret": clientSecret,
            ])
        }

        /// Gets a new token pair (step 6). The old refresh token stops
        /// working, so store the returned pair before using it.
        ///
        /// ``OAuthTokenProvider`` calls this for you; call it directly only
        /// if you manage tokens yourself.
        public func refresh(_ refreshToken: String) async throws -> OAuthTokens {
            try await requestTokens([
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": clientID,
                "client_secret": clientSecret,
            ])
        }

        /// Revokes a token, e.g. when the user disconnects or a token may be
        /// compromised. The homeowner then has to authorize the site again.
        public func revoke(_ token: String) async throws {
            _ = try await post("oauth2/revoke-token", body: ["token": token])
        }

        
        // MARK: - Requests

        private func requestTokens(_ body: [String: String]) async throws -> OAuthTokens {
            let data = try await post("oauth2/token", body: body)
            do {
                return try JSONDecoder().decode(OAuthTokenResponse.self, from: data).tokens(receivedAt: now())
            } catch {
                throw SolarEdgeError.decoding(underlying: error)
            }
        }

        /// Sends a JSON `POST` and returns the body of a 2xx response.
        private func post(_ path: String, body: [String: String]) async throws -> Data {
            var request = URLRequest(url: baseURL.appending(path: path))
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try JSONEncoder().encode(body)

            let data: Data
            let response: HTTPURLResponse
            do {
                (data, response) = try await transport.send(request)
            } catch let error as URLError {
                if error.code == .cancelled { throw CancellationError() }
                throw SolarEdgeError.network(error)
            } catch let error where error is SolarEdgeError || error is CancellationError {
                throw error
            } catch {
                throw SolarEdgeError.transport(underlying: error)
            }

            guard (200..<300).contains(response.statusCode) else {
                let details = try? JSONDecoder().decode(OAuthErrorResponse.self, from: data)
                throw OAuthError(statusCode: response.statusCode, code: details?.error, message: details?.errorDescription)
            }
            return data
        }
    }
}
