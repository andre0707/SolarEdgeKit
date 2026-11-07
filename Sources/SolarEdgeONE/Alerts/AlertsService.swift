//
//  AlertsService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The "Alerts" endpoint group.
public struct AlertsService: Sendable {
    let client: APIClient

    /// Fetches one page of equipment and performance alerts of a site.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``SitesService/list(filter:page:pageSize:)``.
    ///   - page: 1-based page number (1...10,000,000).
    ///   - pageSize: Alerts per page (1...100).
    ///   - onlyOpen: `true` for open alerts only, `false` for alerts in any
    ///     status. Defaults to `true`, like the API.
    public func list(
        for siteID: Monitoring.Site.ID,
        page: Int = 1,
        pageSize: Int = 50,
        onlyOpen: Bool = true
    ) async throws -> Monitoring.AlertPage {
        try Self.validatePaging(page: page, pageSize: pageSize)

        let endpoint = SiteAlertsEndpoint(siteID: siteID, page: page, pageSize: pageSize, onlyOpen: onlyOpen)
        let alerts = try await client.send(endpoint).map { try $0.entity }
        return Monitoring.AlertPage(alerts: alerts, page: page, pageSize: pageSize)
    }

    /// Fetches one page of equipment and performance alerts across all
    /// sites your account has access to.
    ///
    /// - Note: Requires an API key; OAuth bearer tokens are rejected with
    ///   ``SolarEdgeError/unsupportedAuthentication(used:supported:)``.
    /// - Parameters:
    ///   - filter: Optional group, type, state and city filters.
    ///   - page: 1-based page number (1...10,000,000).
    ///   - pageSize: Alerts per page (1...100).
    ///   - onlyOpen: `true` for open alerts only, `false` for alerts in any
    ///     status. Defaults to `true`, like the API.
    public func list(
        filter: Monitoring.AlertFilter = Monitoring.AlertFilter(),
        page: Int = 1,
        pageSize: Int = 50,
        onlyOpen: Bool = true
    ) async throws -> Monitoring.AlertPage {
        try Self.validatePaging(page: page, pageSize: pageSize)

        let endpoint = FleetAlertsEndpoint(filter: filter, page: page, pageSize: pageSize, onlyOpen: onlyOpen)
        let alerts = try await client.send(endpoint).map { try $0.entity }
        return Monitoring.AlertPage(alerts: alerts, page: page, pageSize: pageSize)
    }

    /// Both alert endpoints share the same paging limits.
    private static func validatePaging(page: Int, pageSize: Int) throws {
        guard (1...10_000_000).contains(page) else {
            throw SolarEdgeError.invalidRequest("page must be in 1...10000000, got \(page)")
        }
        guard (1...100).contains(pageSize) else {
            throw SolarEdgeError.invalidRequest("pageSize must be in 1...100, got \(pageSize)")
        }
    }
}
