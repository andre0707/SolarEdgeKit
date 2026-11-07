//
//  InventoryService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The "Inventory" endpoint group.
public struct InventoryService: Sendable {
    let client: APIClient

    /// The devices installed at a site: inverters, meters, batteries,
    /// power optimizers, gateways and more.
    ///
    /// Use it to find the serial numbers for the per-device endpoints.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - siteID: The site to query, e.g. from ``SitesService/list(filter:page:pageSize:)``.
    ///   - types: The kinds of device to return. Defaults to inverters only,
    ///     like the API. Must not be empty.
    public func devices(
        for siteID: Monitoring.Site.ID,
        types: Set<Monitoring.DeviceType> = [.inverter]
    ) async throws -> [Monitoring.Device] {
        guard !types.isEmpty else {
            throw SolarEdgeError.invalidRequest("types must not be empty")
        }

        return try await client.send(SiteInventoryEndpoint(siteID: siteID, types: types)).map { try $0.entity }
    }

    /// The record of one device: manufacturer, model, firmware,
    /// communication type and more.
    ///
    /// - Note: Accepts an API key or an OAuth bearer token.
    /// - Parameters:
    ///   - serialNumber: The device's serial number, e.g. from ``devices(for:types:)``.
    ///   - siteID: The site the device belongs to.
    public func device(
        _ serialNumber: String,
        for siteID: Monitoring.Site.ID
    ) async throws -> Monitoring.Device {
        try validateSerialNumber(serialNumber)

        return try await client.send(DeviceInfoEndpoint(siteID: siteID, serialNumber: serialNumber)).entity
    }
}
