//
//  APIClient.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Builds, authenticates, sends and decodes requests for any `Endpoint`.
/// Shared by the ONE and Designer targets; not part of the public API.
package struct APIClient: Sendable {
    package let baseURL: URL
    package let credentials: SolarEdgeCredentials
    package let transport: any HTTPTransport
    /// Called with the `x-ratelimit-*` headers of every response that has them.
    package let onRateLimit: (@Sendable (SolarEdgeError.RateLimit) -> Void)?

    package init(
        baseURL: URL,
        credentials: SolarEdgeCredentials,
        transport: any HTTPTransport,
        onRateLimit: (@Sendable (SolarEdgeError.RateLimit) -> Void)? = nil
    ) {
        self.baseURL = baseURL
        self.credentials = credentials
        self.transport = transport
        self.onRateLimit = onRateLimit
    }

    package func send<E: Endpoint>(_ endpoint: E) async throws -> E.Response {
        guard endpoint.supportedAuthentication.contains(credentials.method) else {
            throw SolarEdgeError.unsupportedAuthentication(
                used: credentials.method,
                supported: endpoint.supportedAuthentication
            )
        }

        var request = try makeRequest(for: endpoint)
        let token = try await credentials.authorize(&request)
        var (data, response) = try await perform(request)

        // A rejected bearer token gets one more chance, with a fresh token.
        if response.statusCode == 401, case .bearerToken(let provider) = credentials, let token {
            await provider.invalidate(token)
            if try await credentials.authorize(&request) != token {
                (data, response) = try await perform(request)
            }
        }

        try Self.validate(response, data: data)

        // Raw responses, e.g. images, are returned as they are.
        if E.Response.self == Data.self {
            return data as! E.Response
        }

        // An optional response type accepts a 200 without a body.
        if data.allSatisfy(Self.isWhitespace), let empty = E.Response.self as? any EmptyBodyDecodable.Type {
            return empty.emptyBody as! E.Response
        }

        do {
            return try JSONDecoder().decode(E.Response.self, from: data)
        } catch {
            throw SolarEdgeError.decoding(underlying: error)
        }
    }

    private static func isWhitespace(_ byte: UInt8) -> Bool {
        byte == 0x20 || byte == 0x0A || byte == 0x0D || byte == 0x09
    }

    
    // MARK: - Request

    /// The request without its authentication header.
    private func makeRequest<E: Endpoint>(for endpoint: E) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw SolarEdgeError.invalidRequest("Could not build URL for \(endpoint.path)")
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
            // URLComponents leaves "+" unescaped, but servers read it as a space.
            components.percentEncodedQuery = components.percentEncodedQuery?
                .replacingOccurrences(of: "+", with: "%2B")
        }

        guard let url = components.url else {
            throw SolarEdgeError.invalidRequest("Could not build URL for \(endpoint.path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue(endpoint.accept, forHTTPHeaderField: "Accept")
        if let body = endpoint.body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw SolarEdgeError.invalidRequest("Could not encode the request body: \(error)")
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }

    
    // MARK: - Transport

    private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await transport.send(request)
            if let onRateLimit, let limits = Self.rateLimit(from: response) {
                onRateLimit(limits)
            }
            return (data, response)
        } catch let error as URLError {
            if error.code == .cancelled { throw CancellationError() }
            throw SolarEdgeError.network(error)
        } catch let error where error is SolarEdgeError || error is CancellationError {
            throw error
        } catch {
            throw SolarEdgeError.transport(underlying: error)
        }
    }

    
    // MARK: - Response

    private static func validate(_ response: HTTPURLResponse, data: Data) throws {
        let status = response.statusCode
        guard !(200..<300).contains(status) else { return }

        let details = errorDetails(from: data, statusCode: status)
        switch status {
        case 401:
            throw SolarEdgeError.unauthorized(details: details)
        case 403:
            throw SolarEdgeError.forbidden(details: details)
        case 404:
            throw SolarEdgeError.notFound(details: details)
        case 429:
            let retryAfter = response.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
            throw SolarEdgeError.rateLimited(retryAfter: retryAfter, details: details, limits: rateLimit(from: response))
        default:
            throw SolarEdgeError.http(statusCode: status, details: details)
        }
    }

    /// The `x-ratelimit-*` headers of a response. A window is filled only if both
    /// its headers are present whole numbers; `nil` if none is.
    static func rateLimit(from response: HTTPURLResponse) -> SolarEdgeError.RateLimit? {
        func window(_ name: String) -> SolarEdgeError.RateLimit.Window? {
            guard let limit = response.value(forHTTPHeaderField: "x-ratelimit-limit-\(name)").flatMap(Int.init),
                  let remaining = response.value(forHTTPHeaderField: "x-ratelimit-remaining-\(name)").flatMap(Int.init)
            else { return nil }
            return SolarEdgeError.RateLimit.Window(limit: limit, remaining: remaining)
        }

        let limits = SolarEdgeError.RateLimit(perMinute: window("minute"), perMonth: window("month"), perSecond: window("second"))
        return limits.perMinute == nil && limits.perMonth == nil && limits.perSecond == nil ? nil : limits
    }

    /// Best-effort reading of an error body. The spec sends a gateway error
    /// for `401` and `429` and `problem+json` otherwise; the other shape is
    /// tried as a fallback in case a server sends it anyway.
    static func errorDetails(from data: Data, statusCode: Int) -> SolarEdgeError.ErrorDetails? {
        let decoder = JSONDecoder()
        let gateway = (try? decoder.decode(GatewayErrorDTO.self, from: data))?.entity
        let problem = (try? decoder.decode(ProblemDetailDTO.self, from: data))?.entity

        return [401, 429].contains(statusCode) ? gateway ?? problem : problem ?? gateway
    }
}
