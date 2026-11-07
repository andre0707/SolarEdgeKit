//
//  MeterTelemetryEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Meter Telemetry, for specific meters. Authentication: API key or OAuth
/// bearer token.
struct MeterTelemetryEndpoint: Endpoint {
    typealias Response = MeterTelemetryResponseDTO

    let siteID: Monitoring.Site.ID
    let serialNumbers: [String]
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution

    /// `GET /sites/{id}/meters/{serialNumbers}/telemetry`, with the serial
    /// numbers comma-separated.
    var path: String { "sites/\(siteID.rawValue)/meters/\(serialNumbers.joined(separator: ","))/telemetry" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}

/// Site Meter Telemetry, for all active meters of a site. Authentication:
/// API key or OAuth bearer token.
struct SiteMeterTelemetryEndpoint: Endpoint {
    typealias Response = MeterTelemetryResponseDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution

    /// `GET /sites/{id}/meters/telemetry`
    var path: String { "sites/\(siteID.rawValue)/meters/telemetry" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}
