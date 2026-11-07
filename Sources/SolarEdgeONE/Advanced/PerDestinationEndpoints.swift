//
//  PerDestinationEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Power Per Destination. Authentication: API key or OAuth bearer token.
struct PowerPerDestinationEndpoint: Endpoint {
    typealias Response = PowerPerDestinationDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?
    let resolution: Monitoring.IntradayResolution

    /// `GET /sites/{id}/power/per-destination`
    var path: String { "sites/\(siteID.rawValue)/power/per-destination" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}

/// Energy Per Destination. Authentication: API key or OAuth bearer token.
struct EnergyPerDestinationEndpoint: Endpoint {
    typealias Response = EnergyPerDestinationDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution

    /// `GET /sites/{id}/energy/per-destination`
    var path: String { "sites/\(siteID.rawValue)/energy/per-destination" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}
