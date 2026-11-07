//
//  MetersService+Measurements.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// "Meter Measurements": one metric of one meter per request.
///
/// For several metrics or meters at once, see
/// ``MetersService/telemetry(for:serialNumbers:from:to:resolution:)``.
///
/// All methods accept an API key or an OAuth bearer token. Each metric
/// works only on a meter configured for it, e.g. production power on a
/// production meter; the API answers other meters with an error.
///
/// Power values are averages and energy values sums, each in the bucket
/// that **starts** at its timestamp; ``Monitoring/Resolution/day`` and coarser buckets
/// start at midnight in the site's time zone. When `from` is given, a period
/// that is clearly too long for the resolution, or `to` before `from`, is
/// rejected before any request is sent; a missing `to` counts as now.
///
/// Parameters of the power methods:
/// - `siteID`: The site the meter belongs to.
/// - `serialNumber`: The meter, e.g. from ``InventoryService/devices(for:types:)``.
/// - `from`, `to`: The period. Default to midnight today (local site time) and now.
/// - `resolution`: Bucket size. Defaults to a quarter hour, like the API.
/// - `unit`: Defaults to watts, like the API. ``Monitoring/Power/gigaWatt`` is not supported.
///
/// The energy methods take any ``Monitoring/Resolution`` and an ``Monitoring/Energy`` unit,
/// defaulting to watt-hours; ``Monitoring/Energy/gigaWattHour`` is not supported.
extension MetersService {
    /// PV production power measured by a production meter.
    public func productionPower(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                                resolution: Monitoring.IntradayResolution = .quarterHour, unit: Monitoring.Power = .watt) async throws -> Monitoring.Measurements<Monitoring.Power> {
        try await metric(.productionPower, siteID, serialNumber, from, to, resolution.resolution, try powerUnitQueryValue(unit))
    }

    /// PV production energy measured by a production meter.
    public func productionEnergy(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                                 resolution: Monitoring.Resolution = .quarterHour, unit: Monitoring.Energy = .wattHour) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.productionEnergy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit))
    }

    /// Consumption power measured by a consumption meter.
    public func consumptionPower(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                                 resolution: Monitoring.IntradayResolution = .quarterHour, unit: Monitoring.Power = .watt) async throws -> Monitoring.Measurements<Monitoring.Power> {
        try await metric(.consumptionPower, siteID, serialNumber, from, to, resolution.resolution, try powerUnitQueryValue(unit))
    }

    /// Consumption energy measured by a consumption meter.
    public func consumptionEnergy(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                                  resolution: Monitoring.Resolution = .quarterHour, unit: Monitoring.Energy = .wattHour) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.consumptionEnergy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit))
    }

    /// Power drawn from the grid, measured by an import meter.
    public func importPower(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                            resolution: Monitoring.IntradayResolution = .quarterHour, unit: Monitoring.Power = .watt) async throws -> Monitoring.Measurements<Monitoring.Power> {
        try await metric(.importPower, siteID, serialNumber, from, to, resolution.resolution, try powerUnitQueryValue(unit))
    }

    /// Energy drawn from the grid, measured by an import meter.
    public func importEnergy(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                             resolution: Monitoring.Resolution = .quarterHour, unit: Monitoring.Energy = .wattHour) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.importEnergy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit))
    }

    /// Power fed into the grid, measured by an export meter.
    public func exportPower(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                            resolution: Monitoring.IntradayResolution = .quarterHour, unit: Monitoring.Power = .watt) async throws -> Monitoring.Measurements<Monitoring.Power> {
        try await metric(.exportPower, siteID, serialNumber, from, to, resolution.resolution, try powerUnitQueryValue(unit))
    }

    /// Energy fed into the grid, measured by an export meter.
    public func exportEnergy(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                             resolution: Monitoring.Resolution = .quarterHour, unit: Monitoring.Energy = .wattHour) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.exportEnergy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit))
    }

    /// The lifetime energy counters of meters, sampled every 15 minutes.
    ///
    /// Each value is the counter itself at that time, not a delta, so gaps
    /// in the reporting history do not affect it (unlike the energy methods
    /// with ``Monitoring/Resolution/total``).
    ///
    /// Unknown serial numbers, and ones that are not meters, are left out of
    /// the result. Only if none of them is a meter on the site does the API
    /// answer with ``SolarEdgeError/notFound(details:)``.
    ///
    /// - Parameters:
    ///   - siteID: The site to query.
    ///   - serialNumbers: The meters to query. Empty for all active meters of the site.
    ///   - directions: Only these directions. Empty for every direction each meter measures.
    ///   - from: Start of the period. Required by the API.
    ///   - to: End of the period. Must be after `from` and at most one week later.
    public func lifetimeEnergy(
        for siteID: Monitoring.Site.ID,
        serialNumbers: [String] = [],
        directions: Set<Monitoring.MeterDirection> = [],
        from: Date,
        to: Date
    ) async throws -> [Monitoring.MeterLifetimeEnergy] {
        try serialNumbers.forEach(validateSerialNumber)
        try validateLifetimePeriod(from: from, to: to)

        let endpoint = MeterLifetimeEnergyEndpoint(siteID: siteID, serialNumbers: serialNumbers, directions: directions, from: from, to: to)
        return try await client.send(endpoint).entity
    }

    
    // MARK: - Helpers

    private func metric<UnitType>(
        _ metric: MeterMetricEndpoint.Metric,
        _ siteID: Monitoring.Site.ID,
        _ serialNumber: String,
        _ from: Date?,
        _ to: Date?,
        _ resolution: Monitoring.Resolution,
        _ unit: String
    ) async throws -> Monitoring.Measurements<UnitType> {
        try validateSerialNumber(serialNumber)
        try validatePeriod(from: from, to: to, resolution: resolution)

        let endpoint = MeterMetricEndpoint(siteID: siteID, serialNumber: serialNumber, metric: metric,
                                           from: from, to: to, resolution: resolution, unit: unit)
        return try await client.send(endpoint).entity(unit: UnitType.self)
    }
}
