//
//  InvertersService+Status.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// "Inverter Status": device states rather than measurements.
extension InvertersService {
    /// The power limit, operation mode, inverter mode and temperature of
    /// inverters, as the last known value per bucket.
    ///
    /// The status endpoints have their own period limits: 1 week for
    /// ``Monitoring/IntradayResolution/quarterHour`` and 24 hours for ``Monitoring/IntradayResolution/hour``.
    /// When `from` is given, a longer period, or `to` before `from`, is
    /// rejected here, before any request is sent; a missing `to` counts as now.
    ///
    /// Unknown serial numbers are left out of the result. Only if none of
    /// them belongs to the site does the API answer with ``SolarEdgeError/notFound(details:)``.
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
    public func status(
        for siteID: Monitoring.Site.ID,
        serialNumbers: [String] = [],
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.IntradayResolution = .quarterHour
    ) async throws -> Monitoring.InverterStatusReport {
        try serialNumbers.forEach(validateSerialNumber)
        try Self.validateStatusPeriod(from: from, to: to, resolution: resolution)

        if serialNumbers.isEmpty {
            let endpoint = SiteInverterStatusEndpoint(siteID: siteID, from: from, to: to, resolution: resolution)
            return try await client.send(endpoint).entity
        }

        let endpoint = InverterStatusEndpoint(siteID: siteID, serialNumbers: serialNumbers, from: from, to: to, resolution: resolution)
        return try await client.send(endpoint).entity
    }

    /// The status endpoints allow 1 week at a quarter hour, unlike the
    /// 12 hours of the measurement endpoints.
    static func validateStatusPeriod(from: Date?, to: Date?, resolution: Monitoring.IntradayResolution) throws {
        guard let from, let to else { return }

        guard from <= to else {
            throw SolarEdgeError.invalidRequest("'to' is before 'from'")
        }
        let maximumSpan: TimeInterval = switch resolution {
            case .quarterHour: 7 * 24 * 3600
            case .hour: 24 * 3600
        }
        guard to.timeIntervalSince(from) <= maximumSpan else {
            throw SolarEdgeError.invalidRequest("The period is too long for \(resolution.rawValue)")
        }
    }
}
