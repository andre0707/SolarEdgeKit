//
//  SiteInventoryEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Inventory. Authentication: API key or OAuth bearer token.
struct SiteInventoryEndpoint: Endpoint {
    typealias Response = [DeviceDataDTO]

    let siteID: Monitoring.Site.ID
    let types: Set<Monitoring.DeviceType>

    /// `GET /sites/{id}/devices`
    var path: String { "sites/\(siteID.rawValue)/devices" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    /// One `types` item per type, in a stable order.
    var queryItems: [URLQueryItem] {
        Monitoring.DeviceType.allCases
            .filter(types.contains)
            .map { URLQueryItem(name: "types", value: $0.rawValue) }
    }
}
