//
//  InverterMeasurementEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The single-metric time series of one inverter, e.g.
/// `GET /sites/{id}/inverters/{serialNumber}/power`.
/// Authentication: API key or OAuth bearer token.
///
/// The seven metrics differ only in the last path component, the allowed
/// resolutions and whether they take a unit.
struct InverterMetricEndpoint: Endpoint {
    enum Metric: String {
        case power = "power"
        case energy = "energy"
        case consumedAcPower = "consumed-ac-power"
        case consumedAcEnergy = "consumed-ac-energy"
        case voltage = "voltage"
        case current = "current"
        case frequency = "frequency"
    }

    typealias Response = MeasurementsDTO

    let siteID: Monitoring.Site.ID
    let serialNumber: String
    let metric: Metric
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution
    /// `nil` for voltage, current and frequency, which take no unit.
    let unit: String?

    var path: String { "sites/\(siteID.rawValue)/inverters/\(serialNumber)/\(metric.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let from { items.append(URLQueryItem(name: "from", date: from)) }
        if let to { items.append(URLQueryItem(name: "to", date: to)) }
        items.append(URLQueryItem(name: "resolution", value: resolution.rawValue))
        if let unit { items.append(URLQueryItem(name: "unit", value: unit)) }
        return items
    }
}

/// Inverter Lifetime Energy. Authentication: API key or OAuth bearer token.
struct InverterLifetimeEnergyEndpoint: Endpoint {
    typealias Response = InverterLifetimeEnergyResponseDTO

    let siteID: Monitoring.Site.ID
    let serialNumber: String
    let from: Date
    let to: Date

    /// `GET /sites/{id}/inverters/{serialNumber}/lifetime-energy`
    var path: String { "sites/\(siteID.rawValue)/inverters/\(serialNumber)/lifetime-energy" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "from", date: from), URLQueryItem(name: "to", date: to)]
    }
}

/// Site Inverter Lifetime Energy. Authentication: API key or OAuth bearer token.
struct SiteInverterLifetimeEnergyEndpoint: Endpoint {
    typealias Response = SiteInverterLifetimeEnergyResponseDTO

    let siteID: Monitoring.Site.ID
    let from: Date
    let to: Date

    /// `GET /sites/{id}/inverters/lifetime-energy`
    var path: String { "sites/\(siteID.rawValue)/inverters/lifetime-energy" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "from", date: from), URLQueryItem(name: "to", date: to)]
    }
}
