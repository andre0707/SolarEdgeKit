//
//  FleetAlertsEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Fleet Alerts. Authentication: API key only (`X-API-Key`).
struct FleetAlertsEndpoint: Endpoint {
    typealias Response = [AlertDTO]

    let filter: Monitoring.AlertFilter
    let page: Int
    let pageSize: Int
    let onlyOpen: Bool

    /// `GET /alerts`
    var path: String { "alerts" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey] }

    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "alerts-in-page", value: String(pageSize)),
            URLQueryItem(name: "only-open", value: String(onlyOpen)),
        ]
        if let group = filter.group {
            items.append(URLQueryItem(name: "group", value: group.uuidString.lowercased()))
        }
        if let type = filter.type { items.append(URLQueryItem(name: "type", value: type)) }
        if let state = filter.state { items.append(URLQueryItem(name: "state", value: state)) }
        if let city = filter.city { items.append(URLQueryItem(name: "city", value: city)) }
        return items
    }
}
