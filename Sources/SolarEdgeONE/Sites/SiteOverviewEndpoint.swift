//
//  SiteOverviewEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Overview. Authentication: API key or OAuth bearer token.
struct SiteOverviewEndpoint: Endpoint {
    typealias Response = SiteSummaryDTO

    let siteID: Monitoring.Site.ID
    let from: Date?
    let to: Date?

    /// `GET /sites/{id}/overview`
    var path: String { "sites/\(siteID.rawValue)/overview" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    /// Dates are sent in UTC (`2026-10-01T00:00:00Z`).
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let from { items.append(URLQueryItem(name: "from", date: from)) }
        if let to { items.append(URLQueryItem(name: "to", date: to)) }
        return items
    }
}
