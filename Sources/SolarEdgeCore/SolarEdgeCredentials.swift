//
//  SolarEdgeCredentials.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum SolarEdgeCredentials: Sendable {
    /// Sent as the `X-API-Key` header.
    case apiKey(String)
    /// Sent as `Authorization: Bearer <token>`.
    case bearerToken(any AccessTokenProvider)

    public var method: AuthenticationMethod {
        switch self {
        case .apiKey: return .apiKey
        case .bearerToken: return .bearerToken
        }
    }
}

extension SolarEdgeCredentials {
    /// Adds the authentication header. Returns the bearer token it used,
    /// `nil` for an API key.
    @discardableResult
    package func authorize(_ request: inout URLRequest) async throws -> String? {
        switch self {
        case .apiKey(let key):
            request.setValue(key, forHTTPHeaderField: "X-API-Key")
            return nil

        case .bearerToken(let provider):
            let token: String
            do {
                token = try await provider.accessToken()
            } catch let error where error is SolarEdgeError || error is CancellationError {
                throw error
            } catch {
                throw SolarEdgeError.authentication(underlying: error)
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return token
        }
    }
}
