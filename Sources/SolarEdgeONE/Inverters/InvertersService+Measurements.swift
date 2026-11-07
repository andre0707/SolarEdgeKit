//
//  InvertersService+Measurements.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// "Inverter Measurements": one metric of one inverter per request.
///
/// For several metrics or inverters at once, see
/// ``InvertersService/telemetry(for:serialNumbers:from:to:resolution:)``.
///
/// All methods accept an API key or an OAuth bearer token. When both `from`
/// and `to` are given, a period that is clearly too long for the resolution,
/// or `to` before `from`, is rejected before any request is sent: 12 hours
/// for a quarter hour, 24 hours for an hour, and for energy 1 month for a
/// day, 1 year for a week and 3 years for a month.
extension InvertersService {
    /// AC output power. Each value is the average in the bucket that
    /// **starts** at its timestamp.
    ///
    /// - Parameters:
    ///   - siteID: The site the inverter belongs to.
    ///   - serialNumber: The inverter, e.g. from ``InventoryService/devices(for:types:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    ///   - unit: Unit of the returned values. Defaults to watts, like the API.
    ///     ``Monitoring/Power/gigaWatt`` is not supported.
    public func power(
        for siteID: Monitoring.Site.ID,
        serialNumber: String,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.IntradayResolution = .quarterHour,
        unit: Monitoring.Power = .watt
    ) async throws -> Monitoring.Measurements<Monitoring.Power> {
        try await metric(.power, siteID, serialNumber, from, to, resolution.resolution, try powerUnitQueryValue(unit), Monitoring.Power.self)
    }

    /// AC energy produced. Each value is the sum in the bucket that
    /// **starts** at its timestamp; ``Monitoring/Resolution/day`` and coarser buckets
    /// start at midnight in the site's time zone.
    ///
    /// - Parameters:
    ///   - siteID: The site the inverter belongs to.
    ///   - serialNumber: The inverter, e.g. from ``InventoryService/devices(for:types:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    ///   - unit: Unit of the returned values. Defaults to watt-hours, like
    ///     the API. ``Monitoring/Energy/gigaWattHour`` is not supported.
    public func energy(
        for siteID: Monitoring.Site.ID,
        serialNumber: String,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.Resolution = .quarterHour,
        unit: Monitoring.Energy = .wattHour
    ) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.energy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit), Monitoring.Energy.self)
    }

    /// AC power drawn by the inverter, e.g. when charging from the grid or
    /// other AC sources. Each value is the average in the bucket that
    /// **starts** at its timestamp.
    ///
    /// - Parameters: Same as ``power(for:serialNumber:from:to:resolution:unit:)``.
    public func consumedAcPower(
        for siteID: Monitoring.Site.ID,
        serialNumber: String,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.IntradayResolution = .quarterHour,
        unit: Monitoring.Power = .watt
    ) async throws -> Monitoring.Measurements<Monitoring.Power> {
        try await metric(.consumedAcPower, siteID, serialNumber, from, to, resolution.resolution, try powerUnitQueryValue(unit), Monitoring.Power.self)
    }

    /// AC energy drawn by the inverter, e.g. charged from the grid or other
    /// AC sources. This is not the site's imported energy.
    ///
    /// - Parameters: Same as ``energy(for:serialNumber:from:to:resolution:unit:)``.
    public func consumedAcEnergy(
        for siteID: Monitoring.Site.ID,
        serialNumber: String,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.Resolution = .quarterHour,
        unit: Monitoring.Energy = .wattHour
    ) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try await metric(.consumedAcEnergy, siteID, serialNumber, from, to, resolution, try energyUnitQueryValue(unit), Monitoring.Energy.self)
    }

    /// AC grid voltage, averaged across the active phases (L1 only on
    /// single-phase inverters). Each value covers the bucket that **ends**
    /// at its timestamp.
    ///
    /// - Parameters:
    ///   - siteID: The site the inverter belongs to.
    ///   - serialNumber: The inverter, e.g. from ``InventoryService/devices(for:types:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    public func voltage(
        for siteID: Monitoring.Site.ID,
        serialNumber: String,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.IntradayResolution = .quarterHour
    ) async throws -> Monitoring.Measurements<Monitoring.Voltage> {
        try await metric(.voltage, siteID, serialNumber, from, to, resolution.resolution, nil, Monitoring.Voltage.self)
    }

    /// AC current, derived as power ÷ voltage, not measured. Each value
    /// covers the bucket that **starts** at its timestamp.
    ///
    /// - Parameters: Same as ``voltage(for:serialNumber:from:to:resolution:)``.
    public func current(
        for siteID: Monitoring.Site.ID,
        serialNumber: String,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.IntradayResolution = .quarterHour
    ) async throws -> Monitoring.Measurements<Monitoring.ElectricCurrent> {
        try await metric(.current, siteID, serialNumber, from, to, resolution.resolution, nil, Monitoring.ElectricCurrent.self)
    }

    /// AC grid frequency, averaged across the active phases (L1 only on
    /// single-phase inverters). Each value covers the bucket that **ends**
    /// at its timestamp.
    ///
    /// - Parameters: Same as ``voltage(for:serialNumber:from:to:resolution:)``.
    public func frequency(
        for siteID: Monitoring.Site.ID,
        serialNumber: String,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.IntradayResolution = .quarterHour
    ) async throws -> Monitoring.Measurements<Monitoring.Frequency> {
        try await metric(.frequency, siteID, serialNumber, from, to, resolution.resolution, nil, Monitoring.Frequency.self)
    }

    /// One inverter's lifetime energy counter, sampled every 15 minutes.
    ///
    /// Each value is the counter itself at that time, not a delta, so gaps
    /// in the reporting history do not affect it (unlike
    /// ``energy(for:serialNumber:from:to:resolution:unit:)`` with
    /// ``Monitoring/Resolution/total``).
    ///
    /// - Parameters:
    ///   - siteID: The site the inverter belongs to.
    ///   - serialNumber: The inverter, e.g. from ``InventoryService/devices(for:types:)``.
    ///   - from: Start of the period. Required by the API.
    ///   - to: End of the period. Must be after `from` and at most one week later.
    public func lifetimeEnergy(
        for siteID: Monitoring.Site.ID,
        serialNumber: String,
        from: Date,
        to: Date
    ) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        try validateSerialNumber(serialNumber)
        try validateLifetimePeriod(from: from, to: to)

        let endpoint = InverterLifetimeEnergyEndpoint(siteID: siteID, serialNumber: serialNumber, from: from, to: to)
        return try await client.send(endpoint).entity
    }

    /// The lifetime energy counters of every active inverter of a site,
    /// sampled every 15 minutes.
    ///
    /// An inverter that reported nothing in the period is still listed,
    /// with no values. A site without active inverters returns an empty array.
    ///
    /// - Parameters:
    ///   - siteID: The site to query.
    ///   - from: Start of the period. Required by the API.
    ///   - to: End of the period. Must be after `from` and at most one week later.
    public func lifetimeEnergy(
        for siteID: Monitoring.Site.ID,
        from: Date,
        to: Date
    ) async throws -> [Monitoring.InverterLifetimeEnergy] {
        try validateLifetimePeriod(from: from, to: to)

        let endpoint = SiteInverterLifetimeEnergyEndpoint(siteID: siteID, from: from, to: to)
        return try await client.send(endpoint).entity
    }

    
    // MARK: - Helpers

    private func metric<UnitType>(
        _ metric: InverterMetricEndpoint.Metric,
        _ siteID: Monitoring.Site.ID,
        _ serialNumber: String,
        _ from: Date?,
        _ to: Date?,
        _ resolution: Monitoring.Resolution,
        _ unit: String?,
        _ unitType: UnitType.Type
    ) async throws -> Monitoring.Measurements<UnitType> {
        try validateSerialNumber(serialNumber)
        try validatePeriod(from: from, to: to, resolution: resolution)

        let endpoint = InverterMetricEndpoint(siteID: siteID, serialNumber: serialNumber, metric: metric,
                                              from: from, to: to, resolution: resolution, unit: unit)
        return try await client.send(endpoint).entity(unit: unitType)
    }
}
