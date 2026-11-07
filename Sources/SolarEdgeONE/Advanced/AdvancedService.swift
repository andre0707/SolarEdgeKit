//
//  AdvancedService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The Advanced Monitoring API: per-destination breakdowns, live power
/// flow, Weather Guard and battery backup reserve.
///
/// Only available on the Pro and Enterprise tiers; other API keys get
/// ``SolarEdgeError/forbidden(details:)``. All methods accept an API key or
/// an OAuth bearer token.
public struct AdvancedService: Sendable {
    let client: APIClient

    /// The site's PV production power split by destination (self-consumption,
    /// storage, grid), and its consumption split by source (PV, storage,
    /// grid), as a time series.
    ///
    /// Each value covers the bucket that **starts** at its timestamp. When
    /// `from` is given, a period longer than 12 hours (quarter hour) or 24
    /// hours (hour), or `to` before `from`, is rejected here, before any
    /// request is sent; a missing `to` counts as now.
    ///
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``SitesService/list(filter:page:pageSize:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    public func powerPerDestination(
        for siteID: Monitoring.Site.ID,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.IntradayResolution = .quarterHour
    ) async throws -> Monitoring.PerDestination<Monitoring.Power> {
        try validatePeriod(from: from, to: to, resolution: resolution.resolution)

        let endpoint = PowerPerDestinationEndpoint(siteID: siteID, from: from, to: to, resolution: resolution)
        return try await client.send(endpoint).entity
    }

    /// The site's PV production energy split by destination, and its
    /// consumption split by source, as a time series.
    ///
    /// Each value covers the bucket that **starts** at its timestamp;
    /// ``Monitoring/Resolution/day`` and coarser buckets start at midnight in the site's
    /// time zone. The API limits the period per resolution, like
    /// ``SitesService/energy(for:from:to:resolution:unit:)``; a period that is
    /// clearly too long, or `to` before `from`, is rejected here, before any
    /// request is sent.
    ///
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``SitesService/list(filter:page:pageSize:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    public func energyPerDestination(
        for siteID: Monitoring.Site.ID,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.Resolution = .quarterHour
    ) async throws -> Monitoring.PerDestination<Monitoring.Energy> {
        try validatePeriod(from: from, to: to, resolution: resolution)

        let endpoint = EnergyPerDestinationEndpoint(siteID: siteID, from: from, to: to, resolution: resolution)
        return try await client.send(endpoint).entity
    }

    /// The latest power-flow sample of the site: power on the PV, load,
    /// storage and grid nodes, and its direction.
    ///
    /// Without a live session, this is the last sample of the standard
    /// 5-minute polling (``Monitoring/PowerFlow/refreshRate`` is `300`). For fresh data
    /// every few seconds, start a session with ``startLivePowerFlow(for:)``
    /// first. Check ``Monitoring/PowerFlow/updatedAt`` before using the values.
    ///
    /// - Parameter siteID: The site to query.
    public func powerFlow(for siteID: Monitoring.Site.ID) async throws -> Monitoring.PowerFlow {
        try await client.send(SitePowerFlowEndpoint(siteID: siteID)).entity
    }

    /// Starts a live power-flow session for the site, which runs for one
    /// minute. While it runs, ``powerFlow(for:)`` returns samples every few
    /// seconds.
    ///
    /// This is the only call in the Monitoring API that changes something.
    /// Live data needs supported firmware and an Ethernet, Wi-Fi or (US only)
    /// LTE connection; a successful call does not guarantee it. Confirm with
    /// ``powerFlow(for:)``: ``Monitoring/PowerFlow/isLive`` becomes `true`.
    ///
    /// - Note: With OAuth, the token needs the `SITE_DATA` scope.
    /// - Parameter siteID: The site to start the session for.
    /// - Returns: The API's confirmation, or `nil` if it sent no body (the
    ///   spec describes both).
    @discardableResult
    public func startLivePowerFlow(for siteID: Monitoring.Site.ID) async throws -> Monitoring.LivePowerFlowStart? {
        try await client.send(StartLivePowerFlowEndpoint(siteID: siteID))?.entity
    }

    /// Whether Weather Guard storm mode is currently enabled for the site.
    ///
    /// Read-only: changing it is planned for the separate SolarEdge Fleet
    /// Management API.
    ///
    /// - Parameter siteID: The site to query.
    public func weatherGuard(for siteID: Monitoring.Site.ID) async throws -> Monitoring.WeatherGuard {
        try await client.send(WeatherGuardEndpoint(siteID: siteID)).entity
    }

    /// The site's battery backup reserve: the minimum state of charge the
    /// battery keeps for a grid outage.
    ///
    /// Read-only: changing it is planned for the separate SolarEdge Fleet
    /// Management API.
    ///
    /// - Parameter siteID: The site to query.
    public func backupReserve(for siteID: Monitoring.Site.ID) async throws -> Monitoring.BatteryBackupReserve {
        try await client.send(BatteryBackupReserveEndpoint(siteID: siteID)).entity
    }
}
