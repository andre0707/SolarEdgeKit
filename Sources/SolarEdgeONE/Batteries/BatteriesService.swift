//
//  BatteriesService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The battery endpoint groups of the spec: "Storage Telemetry", "Storage
/// Status" and "Battery Measurements" (see `BatteriesService+Measurements.swift`).
///
/// The API calls batteries "storage" in its paths. All methods accept an
/// API key or an OAuth bearer token.
public struct BatteriesService: Sendable {
    let client: APIClient

    /// Several metrics per battery in one request: charge and discharge
    /// power and energy, remaining energy, state of energy and AC grid
    /// charging energy.
    ///
    /// ``Monitoring/Resolution/quarterHour`` and ``Monitoring/Resolution/hour`` return all
    /// metrics; every other resolution only the energy metrics. See
    /// ``Monitoring/BatteryTelemetry`` for what each metric means.
    ///
    /// The API limits the period per resolution, like
    /// ``SitesService/energy(for:from:to:resolution:unit:)``. When both
    /// `from` and `to` are given, a period that is clearly too long, or `to`
    /// before `from`, is rejected here, before any request is sent.
    ///
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``SitesService/list(filter:page:pageSize:)``.
    ///   - serialNumbers: The batteries to query, e.g. from
    ///     ``InventoryService/devices(for:types:)`` with ``Monitoring/DeviceType/battery``.
    ///     Empty for all active batteries of the site.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    /// - Returns: The telemetry per battery, keyed by serial number.
    public func telemetry(
        for siteID: Monitoring.Site.ID,
        serialNumbers: [String] = [],
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.Resolution = .quarterHour
    ) async throws -> [String: Monitoring.BatteryTelemetry] {
        try serialNumbers.forEach(validateSerialNumber)
        try validatePeriod(from: from, to: to, resolution: resolution)

        let endpoint = StorageTelemetryEndpoint(siteID: siteID, serialNumbers: serialNumbers, from: from, to: to, resolution: resolution)
        return try await client.send(endpoint).entity
    }

    /// The state code and internal temperature of batteries, as the last
    /// known value per quarter hour.
    ///
    /// The API allows at most one week. When `from` is given, a longer
    /// period, or `to` before `from`, is rejected here, before any request
    /// is sent; a missing `to` counts as now.
    ///
    /// Serial numbers are not checked against the site: unknown ones, ones
    /// that are not batteries, and batteries that reported nothing are
    /// simply absent from the result.
    ///
    /// - Parameters:
    ///   - siteID: The site to query.
    ///   - serialNumbers: The batteries to query. Empty for all active batteries of the site.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    public func status(
        for siteID: Monitoring.Site.ID,
        serialNumbers: [String] = [],
        from: Date? = nil,
        to: Date? = nil
    ) async throws -> Monitoring.BatteryStatusReport {
        try serialNumbers.forEach(validateSerialNumber)
        if let from {
            let to = to ?? Date()
            guard from <= to else {
                throw SolarEdgeError.invalidRequest("'to' is before 'from'")
            }
            guard to.timeIntervalSince(from) <= 7 * 24 * 3600 else {
                throw SolarEdgeError.invalidRequest("The period may be at most one week")
            }
        }

        let endpoint = StorageStatusEndpoint(siteID: siteID, serialNumbers: serialNumbers, from: from, to: to)
        return try await client.send(endpoint).entity
    }
}
