//
//  SitePerformanceEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Performance. Authentication: API key or OAuth bearer token.
struct SitePerformanceEndpoint: Endpoint {
    typealias Response = SitePerformanceResponseDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?

    /// `GET /sites/{id}/overview/performance`
    var path: String { "sites/\(siteID.rawValue)/overview/performance" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let from { items.append(URLQueryItem(name: "from", date: from)) }
        if let to { items.append(URLQueryItem(name: "to", date: to)) }
        return items
    }
}
