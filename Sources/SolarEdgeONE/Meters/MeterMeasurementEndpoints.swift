//
//  MeterMeasurementEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The single-metric time series of one meter, e.g.
/// `GET /sites/{id}/meters/{serialNumber}/production-power`.
/// Authentication: API key or OAuth bearer token.
///
/// The eight metrics differ only in the last path component and whether
/// they are power or energy.
struct MeterMetricEndpoint: Endpoint {
    enum Metric: String {
        case productionPower = "production-power"
        case productionEnergy = "production-energy"
        case consumptionPower = "consumption-power"
        case consumptionEnergy = "consumption-energy"
        case importPower = "import-power"
        case importEnergy = "import-energy"
        case exportPower = "export-power"
        case exportEnergy = "export-energy"
    }

    typealias Response = MeasurementsDTO

    let siteID: Monitoring.Site.ID
    let serialNumber: String
    let metric: Metric
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution
    let unit: String

    var path: String { "sites/\(siteID.rawValue)/meters/\(serialNumber)/\(metric.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        periodQueryItems(from: from, to: to, resolution: resolution.rawValue)
            + [URLQueryItem(name: "unit", value: unit)]
    }
}

/// Meter Lifetime Energy, for specific meters or, with no serial numbers,
/// for all active meters of a site. Authentication: API key or OAuth bearer token.
struct MeterLifetimeEnergyEndpoint: Endpoint {
    typealias Response = MeterLifetimeEnergyResponseDTO

    let siteID: Monitoring.Site.ID
    /// Empty for Site Meter Lifetime Energy.
    let serialNumbers: [String]
    let directions: Set<Monitoring.MeterDirection>
    let from: Date
    let to: Date

    /// `GET /sites/{id}/meters/{serialNumbers}/lifetime-energy`, with the
    /// serial numbers comma-separated, or `GET /sites/{id}/meters/lifetime-energy`.
    var path: String {
        serialNumbers.isEmpty
            ? "sites/\(siteID.rawValue)/meters/lifetime-energy"
            : "sites/\(siteID.rawValue)/meters/\(serialNumbers.joined(separator: ","))/lifetime-energy"
    }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    /// `meters` is sent only when filtering, comma-separated in a stable order.
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem(name: "from", date: from), URLQueryItem(name: "to", date: to)]
        if !directions.isEmpty {
            let value = Monitoring.MeterDirection.allCases.filter(directions.contains).map(\.rawValue).joined(separator: ",")
            items.append(URLQueryItem(name: "meters", value: value))
        }
        return items
    }
}
