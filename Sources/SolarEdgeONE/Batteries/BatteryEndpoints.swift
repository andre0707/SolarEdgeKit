//
//  BatteryEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Storage Telemetry, for specific batteries or, with no serial numbers,
/// for all active batteries of a site. Authentication: API key or OAuth
/// bearer token.
struct StorageTelemetryEndpoint: Endpoint {
    typealias Response = StorageTelemetryResponseDTO

    let siteID: Monitoring.Site.ID
    /// Empty for Site Storage Telemetry.
    let serialNumbers: [String]
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution

    /// `GET /sites/{id}/storage/{serialNumbers}/telemetry` or `GET /sites/{id}/storage/telemetry`.
    var path: String { storagePath(siteID, serialNumbers, "telemetry") }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
    }
}

/// Storage Status, for specific batteries or, with no serial numbers, for
/// all active batteries of a site. Authentication: API key or OAuth bearer token.
struct StorageStatusEndpoint: Endpoint {
    typealias Response = StorageStatusResponseDTO

    let siteID: Monitoring.Site.ID
    /// Empty for Site Storage Status.
    let serialNumbers: [String]
    let from: Date?
    let to: Date?

    /// `GET /sites/{id}/storage/{serialNumbers}/status` or `GET /sites/{id}/storage/status`.
    var path: String { storagePath(siteID, serialNumbers, "status") }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    /// The only supported resolution is a quarter hour, so none is sent.
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let from { items.append(URLQueryItem(name: "from", date: from)) }
        if let to { items.append(URLQueryItem(name: "to", date: to)) }
        return items
    }
}

/// The single-metric time series of one battery, e.g.
/// `GET /sites/{id}/storage/{serialNumber}/charge-power`.
/// Authentication: API key or OAuth bearer token.
struct BatteryMetricEndpoint: Endpoint {
    enum Metric: String {
        case chargePower = "charge-power"
        case dischargePower = "discharge-power"
        case chargeEnergy = "charge-energy"
        case dischargeEnergy = "discharge-energy"
        case stateOfEnergy = "state-of-energy"
        case remainingEnergy = "remaining-energy"
    }

    typealias Response = MeasurementsDTO

    let siteID: Monitoring.Site.ID
    let serialNumber: String
    let metric: Metric
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution
    let unit: String

    var path: String { "sites/\(siteID.rawValue)/storage/\(serialNumber)/\(metric.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
            + [URLQueryItem(name: "unit", value: unit)]
    }
}

/// Storage Lifetime Energy, for specific batteries or, with no serial
/// numbers, for all active batteries of a site. Authentication: API key or
/// OAuth bearer token.
struct StorageLifetimeEnergyEndpoint: Endpoint {
    typealias Response = StorageLifetimeEnergyResponseDTO

    let siteID: Monitoring.Site.ID
    /// Empty for Site Storage Lifetime Energy.
    let serialNumbers: [String]
    let from: Date
    let to: Date

    /// `GET /sites/{id}/storage/{serialNumbers}/lifetime-energy` or `GET /sites/{id}/storage/lifetime-energy`.
    var path: String { storagePath(siteID, serialNumbers, "lifetime-energy") }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "from", date: from), URLQueryItem(name: "to", date: to)]
    }
}

/// `sites/{id}/storage/{serialNumbers}/{last}`, or without the serial
/// numbers for the whole site.
private func storagePath(_ siteID: Monitoring.Site.ID, _ serialNumbers: [String], _ last: String) -> String {
    serialNumbers.isEmpty
        ? "sites/\(siteID.rawValue)/storage/\(last)"
        : "sites/\(siteID.rawValue)/storage/\(serialNumbers.joined(separator: ","))/\(last)"
}
