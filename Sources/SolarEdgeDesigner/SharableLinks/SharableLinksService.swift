//
//  SharableLinksService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The Designer Sharable Links API: public links to a design's report and
/// proposal, and which parts of the design are complete.
///
/// A site can be addressed by its Designer ID or by its external ID. A
/// missing site or design gives ``SolarEdgeError/notFound(details:)``. All
/// methods accept a Designer API key or a SolarEdge API key.
public struct SharableLinksService: Sendable {
    let client: APIClient

    /// The sharable links of a site's design.
    ///
    /// - Parameters:
    ///   - siteID: The Designer site.
    ///   - design: The design. `nil` for the site's default design.
    ///   - locale: The language of the linked pages, e.g. `en_US` (the API's
    ///     default). `nil` sends none.
    ///   - units: The unit system of the linked pages. `nil` sends none; the
    ///     API then uses ``Designer/UnitSystem/imperial``.
    public func links(
        for siteID: Designer.SiteID,
        design: Designer.DesignID? = nil,
        locale: String? = nil,
        units: Designer.UnitSystem? = nil
    ) async throws -> Designer.SharableLinks {
        try await client.send(SharableLinksEndpoint(site: .id(siteID), design: design, locale: locale, units: units)).entity
    }

    /// The sharable links of a site's design, by the site's external ID.
    ///
    /// - Parameters:
    ///   - externalID: The site's external ID. Must not be empty, `.` or
    ///     `..`, or contain `/`.
    ///   - design: The design. `nil` for the site's default design.
    ///   - locale: The language of the linked pages, e.g. `en_US` (the API's
    ///     default). `nil` sends none.
    ///   - units: The unit system of the linked pages. `nil` sends none; the
    ///     API then uses ``Designer/UnitSystem/imperial``.
    public func links(
        forExternalID externalID: String,
        design: Designer.DesignID? = nil,
        locale: String? = nil,
        units: Designer.UnitSystem? = nil
    ) async throws -> Designer.SharableLinks {
        try validateExternalID(externalID)

        return try await client.send(SharableLinksEndpoint(site: .externalID(externalID), design: design, locale: locale, units: units)).entity
    }
}
