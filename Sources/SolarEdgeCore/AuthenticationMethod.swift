//
//  AuthenticationMethod.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

/// The ways a request can authenticate.
public enum AuthenticationMethod: Sendable, Hashable {
    case apiKey
    case bearerToken
}
