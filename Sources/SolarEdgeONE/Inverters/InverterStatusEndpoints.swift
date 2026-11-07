//
//  InverterStatusEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Inverter Status, for specific inverters. Authentication: API key or
/// OAuth bearer token.
struct InverterStatusEndpoint: Endpoint {
    typealias Response = InverterStatusResponseDTO

    let siteID: Monitoring.Site.ID
    let serialNumbers: [String]
    let from: Date?
    let to: Date?
    let resolution: Monitoring.IntradayResolution

    /// `GET /sites/{id}/inverters/{serialNumbers}/status`, with the serial
    /// numbers comma-separated.
    var path: String { "sites/\(siteID.rawValue)/inverters/\(serialNumbers.joined(separator: ","))/status" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}

/// Site Inverter Status, for all active inverters of a site.
/// Authentication: API key or OAuth bearer token.
struct SiteInverterStatusEndpoint: Endpoint {
    typealias Response = InverterStatusResponseDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?
    let resolution: Monitoring.IntradayResolution

    /// `GET /sites/{id}/inverters/status`
    var path: String { "sites/\(siteID.rawValue)/inverters/status" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}
