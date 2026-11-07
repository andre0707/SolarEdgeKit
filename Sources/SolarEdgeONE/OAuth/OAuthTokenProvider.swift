//
//  OAuthTokenProvider.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 05.11.26.
//

import Foundation
import SolarEdgeCore

extension Monitoring {
    /// Supplies the access token of one OAuth-connected site and refreshes
    /// it shortly before it expires.
    ///
    /// Use one provider, and one client, per site:
    ///
    /// ```swift
    /// let provider = Monitoring.OAuthTokenProvider(tokens: stored, oauth: oauth) { tokens in
    ///     // Called after every refresh: save the new pair, e.g. in the Keychain.
    ///     try? keychain.save(tokens, for: siteID)
    /// }
    /// let client = SolarEdgeONEClient(credentials: .bearerToken(provider))
    /// ```
    ///
    /// Every refresh invalidates the old refresh token, so `onRefresh` must
    /// save the new pair; otherwise the site has to be authorized again
    /// after the next restart. Only one refresh runs at a time, however many
    /// requests need a token at once.
    ///
    /// A refresh token expires after 14 days without use. If your app may
    /// not make requests that often, call ``refresh()`` regularly, e.g. from
    /// a background job.
    ///
    /// If the refresh fails, requests throw
    /// ``SolarEdgeError/authentication(underlying:)``; an ``OAuthError`` as
    /// the underlying error means the site has to be authorized again.
    public actor OAuthTokenProvider: AccessTokenProvider {
        /// The current token pair, the one last passed to `onRefresh`.
        public private(set) var tokens: OAuthTokens

        private let oauth: OAuthClient
        private let onRefresh: @Sendable (OAuthTokens) async -> Void
        private let refreshMargin: TimeInterval
        private let now: @Sendable () -> Date
        private var pendingRefresh: Task<OAuthTokens, any Error>?

        /// - Parameters:
        ///   - tokens: The site's stored pair, or the result of
        ///     ``OAuthClient/exchange(code:)``.
        ///   - oauth: Performs the refresh.
        ///   - refreshMargin: How long before ``OAuthTokens/expiresAt`` to
        ///     refresh, in seconds. Defaults to 5 minutes.
        ///   - onRefresh: Called with every new pair, before it is used. Save
        ///     it there; it replaces the stored pair.
        public init(
            tokens: OAuthTokens,
            oauth: OAuthClient,
            refreshMargin: TimeInterval = 300,
            onRefresh: @escaping @Sendable (OAuthTokens) async -> Void
        ) {
            self.init(tokens: tokens, oauth: oauth, refreshMargin: refreshMargin, now: { Date() }, onRefresh: onRefresh)
        }

        init(
            tokens: OAuthTokens,
            oauth: OAuthClient,
            refreshMargin: TimeInterval,
            now: @escaping @Sendable () -> Date,
            onRefresh: @escaping @Sendable (OAuthTokens) async -> Void
        ) {
            self.tokens = tokens
            self.oauth = oauth
            self.refreshMargin = refreshMargin
            self.now = now
            self.onRefresh = onRefresh
        }

        public func accessToken() async throws -> String {
            if tokens.expiresAt.timeIntervalSince(now()) > refreshMargin {
                return tokens.accessToken
            }
            do {
                return try await refresh().accessToken
            } catch {
                // Inside the margin the old token still works; the next
                // request tries to refresh again.
                if error is CancellationError || tokens.expiresAt <= now() { throw error }
                return tokens.accessToken
            }
        }

        /// Called by the client after a `401`. Marks the token as expired, so
        /// the next ``accessToken()`` refreshes, unless a refresh already
        /// replaced it.
        public func invalidate(_ token: String) async {
            guard token == tokens.accessToken else { return }
            tokens = OAuthTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken, expiresAt: .distantPast)
        }

        /// Refreshes now, whether or not the access token has expired. Joins
        /// a refresh that is already running instead of starting another.
        ///
        /// Call it regularly if your app may go 14 days without a request,
        /// to keep the refresh token alive.
        @discardableResult
        public func refresh() async throws -> OAuthTokens {
            if let pendingRefresh {
                return try await pendingRefresh.value
            }
            // The new pair is saved before anyone can use it.
            let task = Task { [oauth, onRefresh, refreshToken = tokens.refreshToken] in
                let newTokens = try await oauth.refresh(refreshToken)
                await onRefresh(newTokens)
                return newTokens
            }
            pendingRefresh = task
            defer { pendingRefresh = nil }

            let newTokens = try await task.value
            tokens = newTokens
            return newTokens
        }

        /// Revokes the refresh token, which ends the site's connection. The
        /// homeowner has to authorize the site again to reconnect.
        public func revoke() async throws {
            try await oauth.revoke(tokens.refreshToken)
        }
    }
}
