//
//  BatteriesService+Measurements.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// "Battery Measurements": one metric of one battery per request.
///
/// For several metrics or batteries at once, see
/// ``BatteriesService/telemetry(for:serialNumbers:from:to:resolution:)``.
///
/// All values are positive, and each covers the bucket that **starts** at
/// its timestamp; ``Monitoring/Resolution/day`` and coarser buckets start at midnight
/// in the site's time zone. When `from` is given, a period that is clearly
/// too long for the resolution, or `to` before `from`, is rejected before
/// any request is sent; a missing `to` counts as now.
///
/// Parameters of the metric methods:
/// - `siteID`: The site the battery belongs to.
/// - `serialNumber`: The battery, e.g. from ``InventoryService/devices(for:types:)``.
/// - `from`, `to`: The period. Default to midnight today (local site time) and now.
/// - `resolution`: Bucket size. Defaults to a quarter hour, like the API.
/// - `unit`: Defaults to the API's default (watts, watt-hours or percent).
///   ``Monitoring/Power/gigaWatt`` and ``Monitoring/Energy/gigaWattHour`` are not supported.
extension BatteriesService {
    /// Charge power, averaged per bucket.
    public func chargePower(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                            resolution: Monitoring.IntradayResolution = .quarterHour, unit: Monitoring.Power = .watt) async throws -> Monitoring.Measurements<Monitoring.Power> {
        try await metric(.chargePower, siteID, serialNumber, from, to, resolution.resolution, try powerUnitQueryValue(unit))
    }

    /// Discharge power, averaged per bucket.
    public func dischargePower(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                               resolution: Monitoring.IntradayResolution = .quarterHour, unit: Monitoring.Power = .watt) async throws -> Monitoring.Measurements<Monitoring.Power> {
        try await metric(.dischargePower, siteID, serialNumber, from, to, resolution.resolution, try powerUnitQueryValue(unit))
    }

    /// Energy charged into the battery, summed per bucket.
    public func chargeEnergy(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                             resolution: Monitoring.Resolution = .quarterHour, unit: Monitoring.Energy = .wattHour) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.chargeEnergy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit))
    }

    /// Energy discharged from the battery, summed per bucket.
    public func dischargeEnergy(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                                resolution: Monitoring.Resolution = .quarterHour, unit: Monitoring.Energy = .wattHour) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.dischargeEnergy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit))
    }

    /// Energy stored in the battery, averaged per bucket.
    public func remainingEnergy(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                                resolution: Monitoring.Resolution = .quarterHour, unit: Monitoring.Energy = .wattHour) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.remainingEnergy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit))
    }

    /// State of energy as reported by the battery, 0–100, averaged per bucket.
    public func stateOfEnergy(for siteID: Monitoring.Site.ID, serialNumber: String, from: Date? = nil, to: Date? = nil,
                              resolution: Monitoring.IntradayResolution = .quarterHour, unit: Monitoring.Percentage = .percentage) async throws -> Monitoring.Measurements<Monitoring.Percentage> {
        try await metric(.stateOfEnergy, siteID, serialNumber, from, to, resolution.resolution, unit.rawValue)
    }

    /// The lifetime charge and discharge counters of batteries, sampled
    /// every 15 minutes.
    ///
    /// Each value is the counter itself at that time, not a delta, so gaps
    /// in the reporting history do not affect it (unlike
    /// ``chargeEnergy(for:serialNumber:from:to:resolution:unit:)`` with
    /// ``Monitoring/Resolution/total``).
    ///
    /// - Parameters:
    ///   - siteID: The site to query.
    ///   - serialNumbers: The batteries to query. Empty for all active batteries of the site.
    ///   - from: Start of the period. Required by the API.
    ///   - to: End of the period. Must be after `from` and at most one week later.
    public func lifetimeEnergy(
        for siteID: Monitoring.Site.ID,
        serialNumbers: [String] = [],
        from: Date,
        to: Date
    ) async throws -> [Monitoring.BatteryLifetimeEnergy] {
        try serialNumbers.forEach(validateSerialNumber)
        try validateLifetimePeriod(from: from, to: to)

        let endpoint = StorageLifetimeEnergyEndpoint(siteID: siteID, serialNumbers: serialNumbers, from: from, to: to)
        return try await client.send(endpoint).entity
    }

    // MARK: - Helpers

    private func metric<UnitType>(
        _ metric: BatteryMetricEndpoint.Metric,
        _ siteID: Monitoring.Site.ID,
        _ serialNumber: String,
        _ from: Date?,
        _ to: Date?,
        _ resolution: Monitoring.Resolution,
        _ unit: String
    ) async throws -> Monitoring.Measurements<UnitType> {
        try validateSerialNumber(serialNumber)
        try validatePeriod(from: from, to: to, resolution: resolution)

        let endpoint = BatteryMetricEndpoint(siteID: siteID, serialNumber: serialNumber, metric: metric,
                                             from: from, to: to, resolution: resolution, unit: unit)
        return try await client.send(endpoint).entity(unit: UnitType.self)
    }
}
