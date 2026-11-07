//
//  MetersService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The meter endpoint groups: "Meter Telemetry" and "Meter Measurements"
/// (see `MetersService+Measurements.swift`).
public struct MetersService: Sendable {
    let client: APIClient

    /// Several metrics per meter in one request: production, consumption,
    /// import and export, each as power and energy.
    ///
    /// ``Monitoring/Resolution/quarterHour`` and ``Monitoring/Resolution/hour`` return all
    /// metrics; every other resolution only the energy metrics. See
    /// ``Monitoring/MeterTelemetry`` for what each metric means.
    ///
    /// The API limits the period per resolution, like
    /// ``SitesService/energy(for:from:to:resolution:unit:)``. When both
    /// `from` and `to` are given, a period that is clearly too long, or `to`
    /// before `from`, is rejected here, before any request is sent.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``SitesService/list(filter:page:pageSize:)``.
    ///   - serialNumbers: The meters to query, e.g. from
    ///     ``InventoryService/devices(for:types:)`` with ``Monitoring/DeviceType/meter``.
    ///     Empty for all active meters of the site.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    /// - Returns: The telemetry per meter, keyed by serial number.
    public func telemetry(
        for siteID: Monitoring.Site.ID,
        serialNumbers: [String] = [],
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.Resolution = .quarterHour
    ) async throws -> [String: Monitoring.MeterTelemetry] {
        try serialNumbers.forEach(validateSerialNumber)
        try validatePeriod(from: from, to: to, resolution: resolution)

        if serialNumbers.isEmpty {
            let endpoint = SiteMeterTelemetryEndpoint(siteID: siteID, from: from, to: to, resolution: resolution)
            return try await client.send(endpoint).entity
        }

        let endpoint = MeterTelemetryEndpoint(siteID: siteID, serialNumbers: serialNumbers, from: from, to: to, resolution: resolution)
        return try await client.send(endpoint).entity
    }
}
