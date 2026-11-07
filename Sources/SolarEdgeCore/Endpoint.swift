//
//  Endpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

/// Describes one API call. Conforming types are internal to each API target;
/// only `Core` knows how to turn them into network requests.
package protocol Endpoint: Sendable {
    /// The internal DTO the response body decodes into.
    associatedtype Response: Decodable & Sendable

    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    /// Which credentials the endpoint accepts.
    var supportedAuthentication: Set<AuthenticationMethod> { get }
    /// Sent as JSON with `Content-Type: application/json`. `nil` for no body.
    var body: (any Encodable & Sendable)? { get }
    /// The `Accept` header. Defaults to JSON and `problem+json`.
    var accept: String { get }
}

extension Endpoint {
    package var method: HTTPMethod { .get }
    package var queryItems: [URLQueryItem] { [] }
    package var body: (any Encodable & Sendable)? { nil }
    // Errors 400, 403 and 404 come as `problem+json`; without it in
    // `Accept`, a content-negotiating server cannot send them as specified.
    package var accept: String { "application/json, application/problem+json" }
}
