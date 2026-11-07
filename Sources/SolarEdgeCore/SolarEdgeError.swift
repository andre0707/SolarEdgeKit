//
//  SolarEdgeError.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Everything the clients throw, except `CancellationError` when the task
/// is cancelled.
public enum SolarEdgeError: Error, Sendable {
    /// The endpoint does not accept the credentials in use. Thrown before any
    /// network request is made.
    case unsupportedAuthentication(used: AuthenticationMethod, supported: Set<AuthenticationMethod>)
    /// The request could not be built (bad parameter, bad URL).
    case invalidRequest(String)
    /// The ``AccessTokenProvider`` could not supply a token, e.g. because
    /// its refresh failed. `underlying` is the provider's own error.
    case authentication(underlying: any Error)
    /// HTTP 401: a wrong, missing or expired key or token.
    case unauthorized(details: ErrorDetails?)
    /// HTTP 403. Also what you can expect when an endpoint needs a plan or
    /// permission the account does not have.
    case forbidden(details: ErrorDetails?)
    /// HTTP 404.
    case notFound(details: ErrorDetails?)
    /// HTTP 429: the per-minute or monthly limit is used up. `retryAfter`
    /// is in seconds and, for a monthly limit, can be weeks. `limits` tells
    /// which limit was hit, see ``RateLimit/isMonthlyQuotaExhausted``.
    case rateLimited(retryAfter: TimeInterval?, details: ErrorDetails?, limits: RateLimit?)
    /// Any other non-2xx status, e.g. 400 for a parameter the API rejects.
    case http(statusCode: Int, details: ErrorDetails?)
    /// The request never completed (offline, timeout, TLS, ...).
    case network(URLError)
    /// A custom ``HTTPTransport`` threw an error that is neither a
    /// `URLError` nor a `SolarEdgeError`. `underlying` is that error.
    case transport(underlying: any Error)
    /// The transport returned something that is not an HTTP response.
    case invalidResponse
    /// The response body did not match the expected schema.
    case decoding(underlying: any Error)
    /// The response body did not match the expected schema.
    case decodingWithMessage(message: String)
}

extension SolarEdgeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupportedAuthentication(let used, let supported):
            return "This endpoint does not accept \(used) authentication (supported: \(supported))."
        case .invalidRequest(let reason):
            return "Invalid request: \(reason)"
        case .authentication(let underlying):
            return "Could not get an access token: \(underlying.localizedDescription)"
        case .unauthorized(let details):
            return details?.message ?? "The credentials were rejected (HTTP 401)."
        case .forbidden(let details):
            return details?.message ?? "Access denied (HTTP 403)."
        case .notFound(let details):
            return details?.message ?? "Not found (HTTP 404)."
        case .rateLimited(let retryAfter, let details, let limits):
            var reason = details?.message ?? "Rate limited."
            if limits?.isMonthlyQuotaExhausted == true { reason += " The monthly quota is used up." }
            if let retryAfter { return "\(reason) Retry after \(Int(retryAfter)) s." }
            return reason
        case .http(let statusCode, let details):
            return details?.message ?? "Unexpected HTTP status \(statusCode)."
        case .network(let error):
            return error.localizedDescription
        case .transport(let underlying):
            return "The request failed: \(underlying.localizedDescription)"
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decoding(let underlying):
            return "Could not decode the response: \(underlying)"
        case .decodingWithMessage(let message):
            return "Could not decode the response: \(message)"
        }
    }
}


extension SolarEdgeError {
    /// What the server said about an error, as far as its error body tells.
    public struct ErrorDetails: Sendable, Hashable {
        /// Human-readable reason, e.g. `The access token is missing`.
        public let message: String?
        /// Machine-readable error code of the gateway, e.g. `invalid_request`.
        public let code: String?
        /// The request's ID (`request_id` or `traceId`). Quote it when
        /// reporting a problem to SolarEdge.
        public let requestID: String?
        /// Validation errors per parameter name, e.g. for a `400`.
        public let fieldErrors: [String: String]

        public init(message: String?, code: String?, requestID: String?, fieldErrors: [String: String]) {
            self.message = message
            self.code = code
            self.requestID = requestID
            self.fieldErrors = fieldErrors
        }

        var isEmpty: Bool {
            message == nil && code == nil && requestID == nil && fieldErrors.isEmpty
        }
    }
}


extension SolarEdgeError {
    /// The rate limits from the `x-ratelimit-*` headers: part of a `429`,
    /// and passed to a client's `onRateLimit` for every response that has them.
    ///
    /// A key has either a per-minute limit, or a monthly limit together with
    /// a per-second limit; the windows the API did not report are `nil`.
    public struct RateLimit: Sendable, Hashable {
        /// One limit and how many calls are left in its window.
        public struct Window: Sendable, Hashable {
            /// Calls allowed in the window.
            public let limit: Int
            /// Calls left in the current window.
            public let remaining: Int

            public init(limit: Int, remaining: Int) {
                self.limit = limit
                self.remaining = remaining
            }
        }

        /// Calls per minute, for keys with a per-minute limit.
        public let perMinute: Window?
        /// Calls per month, for keys with a monthly limit.
        public let perMonth: Window?
        /// Calls per second, sent together with the monthly limit.
        public let perSecond: Window?

        /// `true` if the monthly quota is used up: the key is blocked until
        /// the monthly reset, so retrying sooner is pointless.
        public var isMonthlyQuotaExhausted: Bool { perMonth?.remaining == 0 }

        public init(perMinute: Window?, perMonth: Window?, perSecond: Window?) {
            self.perMinute = perMinute
            self.perMonth = perMonth
            self.perSecond = perSecond
        }
    }
}
