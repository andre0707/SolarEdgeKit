//
//  InvertersService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The inverter endpoint groups: "Inverter Telemetry", "Inverter
/// Measurements" (see `InvertersService+Measurements.swift`) and "Inverter
/// Status" (see `InvertersService+Status.swift`).
public struct InvertersService: Sendable {
    let client: APIClient

    /// Several metrics per inverter in one request: power, energy, consumed
    /// AC power and energy, voltage, current and frequency.
    ///
    /// ``Monitoring/Resolution/quarterHour`` and ``Monitoring/Resolution/hour`` return all
    /// metrics; every other resolution only energy and consumed AC energy.
    /// See ``Monitoring/InverterTelemetry`` for what each metric means.
    ///
    /// The API limits the period per resolution, like
    /// ``SitesService/energy(for:from:to:resolution:unit:)``. When both
    /// `from` and `to` are given, a period that is clearly too long, or `to`
    /// before `from`, is rejected here, before any request is sent.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``SitesService/list(filter:page:pageSize:)``.
    ///   - serialNumbers: The inverters to query, e.g. from
    ///     ``InventoryService/devices(for:types:)``. Empty for all active
    ///     inverters of the site.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    /// - Returns: The telemetry per inverter, keyed by serial number.
    public func telemetry(
        for siteID: Monitoring.Site.ID,
        serialNumbers: [String] = [],
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.Resolution = .quarterHour
    ) async throws -> [String: Monitoring.InverterTelemetry] {
        try serialNumbers.forEach(validateSerialNumber)
        try validatePeriod(from: from, to: to, resolution: resolution)

        if serialNumbers.isEmpty {
            let endpoint = SiteInverterTelemetryEndpoint(siteID: siteID, from: from, to: to, resolution: resolution)
            return try await client.send(endpoint).entity
        }

        let endpoint = InverterTelemetryEndpoint(siteID: siteID, serialNumbers: serialNumbers, from: from, to: to, resolution: resolution)
        return try await client.send(endpoint).entity
    }
}
