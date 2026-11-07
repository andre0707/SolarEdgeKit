//
//  SiteAlertsEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Alerts. Authentication: API key or OAuth bearer token.
struct SiteAlertsEndpoint: Endpoint {
    typealias Response = [AlertDTO]

    let siteID: Monitoring.Site.ID
    let page: Int
    let pageSize: Int
    let onlyOpen: Bool

    /// `GET /sites/{id}/alerts`
    var path: String { "sites/\(siteID.rawValue)/alerts" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "alerts-in-page", value: String(pageSize)),
            URLQueryItem(name: "only-open", value: String(onlyOpen)),
        ]
    }
}
