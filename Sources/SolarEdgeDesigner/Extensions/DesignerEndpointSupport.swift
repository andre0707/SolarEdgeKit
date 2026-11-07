//
//  DesignerEndpointSupport.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Every Designer endpoint accepts a Designer API key (bearer) or a
/// SolarEdge API key (`X-API-Key`).
let designerAuthentication: Set<AuthenticationMethod> = [.apiKey, .bearerToken]

/// Adds `name=value` only when `value` is not `nil`.
func optionalQueryItem(_ name: String, _ value: String?) -> [URLQueryItem] {
    value.map { [URLQueryItem(name: name, value: $0)] } ?? []
}

/// Rejects an empty or blank value for a required parameter, before any
/// request is sent.
func validateRequired(_ value: String, name: String) throws {
    guard !value.trimmingCharacters(in: .whitespaces).isEmpty else {
        throw SolarEdgeError.invalidRequest("'\(name)' must not be empty")
    }
}
