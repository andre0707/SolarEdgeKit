//
//  BatteryUpsellService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The Designer Battery Upsell API: applies batteries to an existing design,
/// replacing inverters if needed but keeping the rest of the electrical
/// design, and optionally compares the financials with and without them.
///
/// The design is either a Designer site's or one imported from a Monitoring
/// layout; see ``Designer/BatteryUpsellTarget``. Invalid parameters are
/// rejected before any request is sent; batteries the API cannot apply give
/// ``SolarEdgeError/http(statusCode:details:)`` with status `400`. All
/// methods accept a Designer API key or a SolarEdge API key.
public struct BatteryUpsellService: Sendable {
    let client: APIClient

    /// Applies batteries to a design.
    ///
    /// - Returns: How the batteries are distributed, and which inverters
    ///   were replaced.
    public func apply(_ parameters: Designer.BatteryUpsellParameters, to target: Designer.BatteryUpsellTarget) async throws -> Designer.BatteryDistribution {
        try parameters.validate()

        return try await client.send(BatteryUpsellEndpoint(target: target, request: BatteryUpsellRequestDTO(parameters))).batteryDistribution.entity
    }

    /// Applies batteries to a design and compares the financials with and
    /// without them.
    ///
    /// For a Monitoring layout, the financial values the API needs must be
    /// set; see ``Designer/BatteryUpsellFinancialsParameters``.
    public func applyWithFinancials(_ parameters: Designer.BatteryUpsellFinancialsParameters, to target: Designer.BatteryUpsellTarget) async throws -> Designer.BatteryUpsellFinancials {
        try parameters.validate(for: target)

        return try await client.send(BatteryUpsellFinancialsEndpoint(target: target, request: BatteryUpsellFinancialsRequestDTO(parameters))).entity
    }
}
