//
//  URLQueryItem+Date.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension URLQueryItem {
    /// A date query parameter, sent in UTC (`2026-10-01T00:00:00Z`).
    init(name: String, date: Date) {
        self.init(name: name, value: date.formatted(.iso8601))
    }
}

/// The `from`, `to` and `resolution` query shared by the telemetry and
/// status endpoints. Dates are left out when `nil`.
func periodQueryItems(from: Date?, to: Date?, resolution: String) -> [URLQueryItem] {
    var items: [URLQueryItem] = []
    if let from { items.append(URLQueryItem(name: "from", date: from)) }
    if let to { items.append(URLQueryItem(name: "to", date: to)) }
    items.append(URLQueryItem(name: "resolution", value: resolution))
    return items
}
