//
//  AccessTokenProvider.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//


/// Supplies OAuth access tokens. The library never runs the OAuth flow
/// itself: implement this with your own storage and refresh logic.
public protocol AccessTokenProvider: Sendable {
    /// Returns a currently valid access token, refreshing it if necessary.
    func accessToken() async throws -> String

    /// Called when the server rejected `token` with a `401`. Drop it from
    /// your cache, so that the next ``accessToken()`` returns a new one.
    ///
    /// The client then asks for a token once more and repeats the request
    /// once, but only if the new token differs from the rejected one.
    /// Compare with `token` before refreshing: when several requests fail
    /// at the same time, it may already have been replaced.
    ///
    /// The default implementation does nothing, so the `401` is thrown as
    /// ``SolarEdgeError/unauthorized(details:)`` without a retry.
    func invalidate(_ token: String) async
}

extension AccessTokenProvider {
    public func invalidate(_ token: String) async {}
}

/// Returns the same token every time, e.g. a Designer API key, which is sent
/// as a bearer token but does not expire.
public struct StaticTokenProvider: AccessTokenProvider {
    public let token: String

    public init(token: String) {
        self.token = token
    }

    public func accessToken() async throws -> String { token }
}
