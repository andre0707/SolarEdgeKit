//
//  SitesService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The "Site" endpoint group.
public struct SitesService: Sendable {
    let client: APIClient
    
    /// Fetches one page of sites from your account, sub-accounts and
    /// accounts that granted you access.
    ///
    /// - Note: Requires an API key; OAuth bearer tokens are rejected with
    ///   ``SolarEdgeError/unsupportedAuthentication(used:supported:)``.
    /// - Parameters:
    ///   - filter: Optional name, city, state and group filters.
    ///   - page: 1-based page number (1...10,000,000).
    ///   - pageSize: Sites per page (1...1000).
    public func list(
        filter: Monitoring.SiteFilter = Monitoring.SiteFilter(),
        page: Int = 1,
        pageSize: Int = 50
    ) async throws -> Monitoring.SitePage {
        guard (1...10_000_000).contains(page) else {
            throw SolarEdgeError.invalidRequest("page must be in 1...10000000, got \(page)")
        }
        guard (1...1000).contains(pageSize) else {
            throw SolarEdgeError.invalidRequest("pageSize must be in 1...1000, got \(pageSize)")
        }
        
        let response = try await client.send(
            SiteListEndpoint(filter: filter, page: page, pageSize: pageSize)
        )
        let sites = try response.sites.site.map { try $0.entity }
        // A negative count cannot be a total; the mock, for example, sends Int32.min.
        let totalCount = response.sites.count >= 0 ? response.sites.count : nil
        return Monitoring.SitePage(sites: sites, page: page, pageSize: pageSize, totalCount: totalCount)
    }
    
    /// Every matching site, fetched page by page as you iterate.
    ///
    /// ```swift
    /// for try await site in client.sites.all() { print(site.name) }
    /// ```
    ///
    /// The next page is requested only when the sites so far are used up;
    /// `break` stops without further requests. See ``Monitoring/SiteSequence``
    /// for when the sequence ends.
    ///
    /// - Note: Requires an API key, like ``list(filter:page:pageSize:)``.
    /// - Parameters:
    ///   - filter: Optional name, city, state and group filters.
    ///   - pageSize: Sites per request (1...1000). An invalid value is
    ///     thrown by the first iteration.
    public func all(
        filter: Monitoring.SiteFilter = Monitoring.SiteFilter(),
        pageSize: Int = 100
    ) -> Monitoring.SiteSequence {
        Monitoring.SiteSequence(service: self, filter: filter, pageSize: pageSize)
    }
}



extension SitesService {
    /// The full metadata record of one site: account, last update time,
    /// extended location with time zone, and more.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameter siteID: The site to query, e.g. from ``list(filter:page:pageSize:)``.
    public func details(for siteID: Monitoring.Site.ID) async throws -> Monitoring.SiteDetails {
        try await client.send(SiteDetailsEndpoint(siteID: siteID)).entity
    }
}


extension SitesService {
    /// Where the site's solar production went (self-consumption, storage,
    /// grid) and where its consumption came from (PV, storage, grid).
    ///
    /// Without `from` and `to`, the API covers midnight today (local site
    /// time) until now.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``list(filter:page:pageSize:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    public func overview(
        for siteID: Monitoring.Site.ID,
        from: Date? = nil,
        to: Date? = nil
    ) async throws -> Monitoring.SiteOverview {
        try await client.send(SiteOverviewEndpoint(siteID: siteID, from: from, to: to)).entity
    }
}


extension SitesService {
    /// The site's specific yield and performance ratio for a period.
    ///
    /// Without `from` and `to`, the API covers midnight today (local site
    /// time) until now.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``list(filter:page:pageSize:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    public func performance(
        for siteID: Monitoring.Site.ID,
        from: Date? = nil,
        to: Date? = nil
    ) async throws -> Monitoring.SitePerformance {
        try await client.send(SitePerformanceEndpoint(siteID: siteID, from: from, to: to)).entity
    }
}


extension SitesService {
    /// The site's PV production power as a time series.
    ///
    /// Each value is the power in the bucket that **starts** at its timestamp.
    /// On sites with a battery, charging is added to and discharging
    /// subtracted from the inverter output.
    ///
    /// The API limits the period per resolution: 12 hours for
    /// ``Monitoring/IntradayResolution/quarterHour`` and 24 hours for ``Monitoring/IntradayResolution/hour``.
    /// When `from` is given, a longer period, or `to` before `from`, is
    /// rejected here, before any request is sent; a missing `to` counts as now.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``list(filter:page:pageSize:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    ///   - unit: Unit of the returned values. Defaults to watts, like the API.
    ///     ``Monitoring/Power/gigaWatt`` is not supported.
    public func power(
        for siteID: Monitoring.Site.ID,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.IntradayResolution = .quarterHour,
        unit: Monitoring.Power = .watt
    ) async throws -> Monitoring.Measurements<Monitoring.Power> {
        _ = try powerUnitQueryValue(unit)
        try validatePeriod(from: from, to: to, resolution: resolution.resolution)

        let endpoint = SitePowerEndpoint(siteID: siteID, from: from, to: to, resolution: resolution, unit: unit)
        return try await client.send(endpoint).entity(unit: Monitoring.Power.self)
    }
}


extension SitesService {
    /// The site's PV production energy as a time series, e.g. daily,
    /// monthly or yearly totals.
    ///
    /// Each value is the energy in the bucket that **starts** at its timestamp.
    /// On sites with a battery, charging is added to and discharging
    /// subtracted from the inverter output. ``Monitoring/Resolution/total`` returns a
    /// single value for the whole period; for a lifetime total, start at the
    /// installation date.
    ///
    /// The API limits the period per resolution: 12 hours for
    /// ``Monitoring/Resolution/quarterHour``, 24 hours for ``Monitoring/Resolution/hour``, 1 month
    /// for ``Monitoring/Resolution/day``, 1 year for ``Monitoring/Resolution/week`` and 3 years for
    /// ``Monitoring/Resolution/month``. When `from` is given, a period that is clearly
    /// too long, or `to` before `from`, is rejected here, before any request
    /// is sent; a missing `to` counts as now.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``list(filter:page:pageSize:)``.
    ///   - from: Start of the period. Defaults to midnight today, local site time.
    ///   - to: End of the period. Defaults to now.
    ///   - resolution: Bucket size. Defaults to a quarter hour, like the API.
    ///   - unit: Unit of the returned values. Defaults to watt-hours, like the
    ///     API. ``Monitoring/Energy/gigaWattHour`` is not supported by this endpoint.
    public func energy(
        for siteID: Monitoring.Site.ID,
        from: Date? = nil,
        to: Date? = nil,
        resolution: Monitoring.Resolution = .quarterHour,
        unit: Monitoring.Energy = .wattHour
    ) async throws -> Monitoring.Measurements<Monitoring.Energy> {
        guard unit != .gigaWattHour else {
            throw SolarEdgeError.invalidRequest("Site Energy does not support \(unit.rawValue); use WH, KWH or MWH")
        }
        try validatePeriod(from: from, to: to, resolution: resolution)

        let endpoint = SiteEnergyEndpoint(siteID: siteID, from: from, to: to, resolution: resolution, unit: unit)
        return try await client.send(endpoint).entity(unit: Monitoring.Energy.self)
    }
}


extension SitesService {
    /// The site's lifetime production energy, read from a cumulative counter.
    ///
    /// The counter is the production meter's (the sum of all production
    /// meters if there are several), otherwise the sum of the inverters'
    /// counters. Unlike ``energy(for:from:to:resolution:unit:)`` with
    /// ``Monitoring/Resolution/total``, gaps in the reporting history do not affect it.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameter siteID: The site to query, e.g. from ``list(filter:page:pageSize:)``.
    public func lifetimeEnergy(for siteID: Monitoring.Site.ID) async throws -> Monitoring.SiteLifetimeEnergy {
        try await client.send(SiteLifetimeEnergyEndpoint(siteID: siteID)).entity
    }
}


extension SitesService {
    /// The site's lifetime production energy, split into what SolarEdge
    /// measured and what independent external-production meters reported.
    ///
    /// Useful for sites where a non-SolarEdge meter also measures
    /// production. Sites without such meters report the same value twice.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameter siteID: The site to query, e.g. from ``list(filter:page:pageSize:)``.
    public func externalProductionEnergy(for siteID: Monitoring.Site.ID) async throws -> Monitoring.SiteExternalProductionEnergy {
        try await client.send(SiteExternalProductionEnergyEndpoint(siteID: siteID)).entity
    }
}


extension SitesService {
    /// Environmental benefits of a site's lifetime production: avoided CO₂
    /// emissions and the equivalent EV miles driven. The figures are computed
    /// from the site's location and lifetime production.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``list(filter:page:pageSize:)``.
    ///   - unit: Unit system of the returned values. Defaults to metric, like the API.
    public func environmentalBenefits(
        for siteID: Monitoring.Site.ID,
        unit: Monitoring.UnitSystem = .metric
    ) async throws -> Monitoring.EnvironmentalBenefits {
        try await client.send(EnvironmentalBenefitsEndpoint(siteID: siteID, unit: unit)).entity
    }
}
