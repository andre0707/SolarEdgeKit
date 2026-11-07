//
//  EstimationService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The Designer Estimation API: electrical and financial estimations, and
/// the lookup data they are built from (batteries, consumption profiles,
/// grids, PV modules, utility rates and incentives).
///
/// All methods accept a Designer API key or a SolarEdge API key.
public struct EstimationService: Sendable {
    let client: APIClient

    /// The batteries available for estimations.
    ///
    /// - Parameters:
    ///   - manufacturer: Only batteries of this manufacturer, e.g. `solaredge`.
    ///     `nil` for all.
    ///   - phase: Only single- or three-phase batteries. `nil` for both.
    public func batteries(manufacturer: String? = nil, phase: Designer.Phase? = nil) async throws -> [Designer.Battery] {
        try await client.send(BatteriesEndpoint(manufacturer: manufacturer, phase: phase)).map(\.entity)
    }

    /// The predefined consumption profiles of a country.
    ///
    /// - Parameter country: The country code, e.g. `US`. Must not be empty.
    public func consumptionProfiles(country: String) async throws -> [Designer.ConsumptionProfile] {
        try validateRequired(country, name: "country")

        return try await client.send(ConsumptionProfilesEndpoint(country: country)).map(\.entity)
    }

    /// The grids of a country.
    ///
    /// - Parameter country: The country code, e.g. `US`. Must not be empty.
    public func gridCodes(country: String) async throws -> [Designer.GridCode] {
        try validateRequired(country, name: "country")

        return try await client.send(GridCodesEndpoint(country: country)).map(\.entity)
    }

    /// The PV modules available for estimations.
    ///
    /// - Parameter manufacturer: Only modules of this manufacturer. `nil` for all.
    public func pvModules(manufacturer: String? = nil) async throws -> [Designer.PvModule] {
        try await client.send(PvModulesEndpoint(manufacturer: manufacturer)).map(\.entity)
    }

    /// One PV module.
    ///
    /// - Parameter id: The module, e.g. from ``pvModules(manufacturer:)``.
    public func pvModule(_ id: Designer.PvModule.ID) async throws -> Designer.PvModule {
        try await client.send(PvModuleEndpoint(id: id)).entity
    }

    /// The utility providers.
    ///
    /// - Parameters:
    ///   - rateType: Only providers with import or export rates. `nil` for both.
    ///   - country: Only providers in this country, e.g. `US`. `nil` for all.
    ///   - state: Only providers in this state, e.g. `US-NY`. `nil` for all.
    public func utilityProviders(
        rateType: Designer.UtilityRate.RateType? = nil,
        country: String? = nil,
        state: String? = nil
    ) async throws -> [Designer.UtilityProvider] {
        try await client.send(UtilityProvidersEndpoint(rateType: rateType, country: country, state: state)).map(\.entity)
    }

    /// The utility rates (tariffs).
    ///
    /// - Parameters:
    ///   - utilityNames: Only rates of these providers, e.g. from
    ///     ``utilityProviders(rateType:country:state:)``. Empty for all.
    ///   - rateType: Only import or export rates. `nil` for both.
    ///   - orphanRates: Only rates with or without a provider. `nil` for all.
    ///   - country: Only rates in this country, e.g. `US`. `nil` for all.
    ///   - state: Only rates in this state, e.g. `US-NY`. `nil` for all.
    public func utilityRates(
        utilityNames: [String] = [],
        rateType: Designer.UtilityRate.RateType? = nil,
        orphanRates: Designer.UtilityRate.OrphanRatesFilter? = nil,
        country: String? = nil,
        state: String? = nil
    ) async throws -> [Designer.UtilityRate] {
        let endpoint = UtilityRatesEndpoint(utilityNames: utilityNames, rateType: rateType, orphanRates: orphanRates, country: country, state: state)
        return try await client.send(endpoint).map { try $0.entity }
    }

    /// One utility rate.
    ///
    /// - Parameter id: The rate, e.g. from
    ///   ``utilityRates(utilityNames:rateType:orphanRates:country:state:)``.
    public func utilityRate(_ id: Designer.UtilityRate.ID) async throws -> Designer.UtilityRate {
        try await client.send(UtilityRateEndpoint(id: id)).entity
    }

    /// The incentives.
    ///
    /// - Parameters:
    ///   - country: Only incentives in this country, e.g. `US`. `nil` for all.
    ///   - state: Only incentives in this state, e.g. `US-NY`. `nil` for all.
    public func incentives(country: String? = nil, state: String? = nil) async throws -> [Designer.Incentive] {
        try await client.send(IncentivesEndpoint(country: country, state: state)).map(\.entity)
    }

    /// One incentive.
    ///
    /// - Parameter id: The incentive, e.g. from ``incentives(country:state:)``.
    public func incentive(_ id: Designer.Incentive.ID) async throws -> Designer.Incentive {
        try await client.send(IncentiveEndpoint(id: id)).entity
    }

    /// Generates an estimation for the given parameters, without a site.
    ///
    /// Parameters outside the ranges the spec gives are rejected before any
    /// request is sent. If the modules cannot all be wired, the API answers
    /// `400` with a message, which ends up in
    /// ``SolarEdgeError/http(statusCode:details:)``.
    public func estimate(_ parameters: Designer.EstimationParameters) async throws -> Designer.Estimation {
        try parameters.validate()

        return try await client.send(GenerateEstimationEndpoint(parameters: EstimationParamsDTO(parameters))).entity
    }

    /// The estimation of an existing site's default design.
    ///
    /// - Parameter siteID: The Designer site.
    /// - Returns: The estimation, or a message if the site is still in design.
    public func estimation(for siteID: Designer.SiteID) async throws -> Designer.SiteEstimation {
        try await client.send(SiteEstimationEndpoint(siteID: siteID)).entity
    }

    /// The estimation of one design of an existing site.
    ///
    /// - Parameters:
    ///   - siteID: The Designer site.
    ///   - design: The design.
    public func estimation(for siteID: Designer.SiteID, design: Designer.DesignID) async throws -> Designer.Estimation {
        try await client.send(SiteDesignEstimationEndpoint(siteID: siteID, designID: design)).entity
    }
}
