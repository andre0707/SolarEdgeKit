//
//  SitePowerEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Power. Authentication: API key or OAuth bearer token.
struct SitePowerEndpoint: Endpoint {
    typealias Response = MeasurementsDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?
    let resolution: Monitoring.IntradayResolution
    let unit: Monitoring.Power

    /// `GET /sites/{id}/power`
    var path: String { "sites/\(siteID.rawValue)/power" }

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
