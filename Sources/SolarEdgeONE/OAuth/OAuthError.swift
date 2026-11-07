//
//  OAuthError.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 05.11.26.
//

import Foundation

extension Monitoring {
    /// The OAuth endpoints rejected a request (RFC 6749 error response).
    ///
    /// These errors are deterministic: retrying the same request does not
    /// help. `invalid_client` means the client ID or secret is wrong;
    /// `invalid_request` with "Invalid code" means the authorization code was
    /// already used or has expired. When a refresh fails this way, the
    /// homeowner has to authorize the site again.
    ///
    /// Thrown by ``OAuthClient``. During a request, a failed refresh arrives
    /// as ``SolarEdgeError/authentication(underlying:)`` with this error.
    public struct OAuthError: Error, Sendable, Hashable, LocalizedError {
        /// The HTTP status, `400` for the documented errors.
        public let statusCode: Int
        /// The `error` field, e.g. `invalid_client` or `invalid_request`.
        /// `nil` if the body was not an OAuth error response.
        public let code: String?
        /// The `error_description` field, e.g. "Invalid code".
        public let message: String?

        public init(statusCode: Int, code: String?, message: String?) {
            self.statusCode = statusCode
            self.code = code
            self.message = message
        }

        public var errorDescription: String? {
            switch (code, message) {
            case let (code?, message?): return "OAuth error \(code): \(message)"
            case let (code?, nil): return "OAuth error \(code)."
            case let (nil, message?): return message
            case (nil, nil): return "The OAuth request failed with HTTP \(statusCode)."
            }
        }
    }
}

/// The body of an RFC 6749 error response.
struct OAuthErrorResponse: Decodable {
    let error: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}
