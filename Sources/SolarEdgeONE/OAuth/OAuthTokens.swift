//
//  OAuthTokens.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 05.11.26.
//

import Foundation

extension Monitoring {
    /// The token pair of one OAuth-connected site.
    ///
    /// Store it securely, e.g. in the Keychain, keyed by the site ID from the
    /// authorization callback: each site has its own pair. Every refresh
    /// replaces both tokens and invalidates the old refresh token, so always
    /// keep the newest pair; see ``OAuthTokenProvider``.
    public struct OAuthTokens: Codable, Sendable, Hashable {
        /// Sent as `Authorization: Bearer …`. Valid until ``expiresAt``.
        public let accessToken: String
        /// Gets the next pair. Expires after 14 days without use.
        public let refreshToken: String
        /// When ``accessToken`` expires, from the response's `expires_in`.
        public let expiresAt: Date

        public init(accessToken: String, refreshToken: String, expiresAt: Date) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expiresAt = expiresAt
        }
    }
}

/// The body of a successful `/oauth2/token` response.
struct OAuthTokenResponse: Decodable, Sendable {
    let accessToken: String
    let tokenType: String
    /// Seconds.
    let expiresIn: Int
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
    }

    func tokens(receivedAt date: Date) -> Monitoring.OAuthTokens {
        Monitoring.OAuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: date.addingTimeInterval(TimeInterval(expiresIn))
        )
    }
}
