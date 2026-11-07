//
//  SiteListEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site List. Authentication: API key only (`X-API-Key`).
struct SiteListEndpoint: Endpoint {
    typealias Response = SiteListResponseDTO

    let filter: Monitoring.SiteFilter
    let page: Int
    let pageSize: Int
    var path: String { "sites" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey] }

    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sites-in-page", value: String(pageSize)),
        ]
        if let name = filter.name { items.append(URLQueryItem(name: "name", value: name)) }
        if let city = filter.city { items.append(URLQueryItem(name: "city", value: city)) }
        if let state = filter.state { items.append(URLQueryItem(name: "state", value: state)) }
        if let group = filter.group {
            items.append(URLQueryItem(name: "group", value: group.uuidString.lowercased()))
        }
        return items
    }
}
