//
//  SiteEnergyEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Energy. Authentication: API key or OAuth bearer token.
struct SiteEnergyEndpoint: Endpoint {
    typealias Response = MeasurementsDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?
    let resolution: Monitoring.Resolution
    let unit: Monitoring.Energy

    /// `GET /sites/{id}/energy`
    var path: String { "sites/\(siteID.rawValue)/energy" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let from { items.append(URLQueryItem(name: "from", date: from)) }
        if let to { items.append(URLQueryItem(name: "to", date: to)) }
        items.append(URLQueryItem(name: "resolution", value: resolution.rawValue))
        items.append(URLQueryItem(name: "unit", value: unit.rawValue))
        return items
    }
}
