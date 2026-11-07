//
//  DeviceModelsService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The Designer Device Models API: the inverters, optimizers and batteries
/// available for a region, grid and sector.
///
/// Accepts a Designer API key or a SolarEdge API key.
public struct DeviceModelsService: Sendable {
    let client: APIClient

    /// The device models available for a grid, with the design rules in
    /// their inverters.
    ///
    /// ```swift
    /// let models = try await designer.deviceModels.models(for: grid.id, sector: .residential)
    /// ```
    ///
    /// - Parameters:
    ///   - gridID: The grid, e.g. from ``EstimationService/gridCodes(country:)``.
    ///     Must not be empty.
    ///   - countryCode: Only models for this country. `nil` for all.
    ///   - stateCode: Only models for this state. `nil` for all.
    ///   - sector: Only residential or commercial models. `nil` sends no filter.
    public func models(
        for gridID: Designer.GridCode.ID,
        countryCode: String? = nil,
        stateCode: String? = nil,
        sector: Designer.DeviceModels.Sector? = nil
    ) async throws -> Designer.DeviceModels {
        try validateRequired(gridID.rawValue, name: "gridId")

        let endpoint = DeviceModelsEndpoint(gridID: gridID, countryCode: countryCode, stateCode: stateCode, sector: sector)
        return try await client.send(endpoint).entity
    }
}
