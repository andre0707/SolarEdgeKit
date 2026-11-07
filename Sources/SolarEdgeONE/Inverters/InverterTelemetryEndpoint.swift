//
//  InverterTelemetryEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Inverter Telemetry, for specific inverters. Authentication: API key or
/// OAuth bearer token.
struct InverterTelemetryEndpoint: Endpoint {
    typealias Response = InverterTelemetryResponseDTO

    let siteID: Monitoring.Site.ID
    let serialNumbers: [String]
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution

    /// `GET /sites/{id}/inverters/{serialNumbers}/telemetry`, with the
    /// serial numbers comma-separated.
    var path: String { "sites/\(siteID.rawValue)/inverters/\(serialNumbers.joined(separator: ","))/telemetry" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}

/// Site Inverter Telemetry, for all active inverters of a site.
/// Authentication: API key or OAuth bearer token.
struct SiteInverterTelemetryEndpoint: Endpoint {
    typealias Response = InverterTelemetryResponseDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution

    /// `GET /sites/{id}/inverters/telemetry`
    var path: String { "sites/\(siteID.rawValue)/inverters/telemetry" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}
