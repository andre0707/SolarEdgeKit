//
//  ReportsService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The Designer Report Fetching API: the report, details and images of a
/// site marked as done.
///
/// Each site can be addressed by its Designer ID or by the external ID set
/// by the integrator. A site that is not marked as done gives
/// ``SolarEdgeError/http(statusCode:details:)`` with status `400`. All
/// methods accept a Designer API key or a SolarEdge API key.
public struct ReportsService: Sendable {
    let client: APIClient

    /// The report and details of a site.
    ///
    /// - Parameter siteID: The Designer site.
    public func report(for siteID: Designer.SiteID) async throws -> Designer.ReportData {
        try await client.send(SiteReportDataEndpoint(site: .id(siteID))).entity
    }

    /// The report and details of a site, by its external ID.
    ///
    /// - Parameter externalID: The site's external ID. Must not be empty,
    ///   `.` or `..`, or contain `/`.
    public func report(forExternalID externalID: String) async throws -> Designer.ReportData {
        try validateExternalID(externalID)

        return try await client.send(SiteReportDataEndpoint(site: .externalID(externalID))).entity
    }

    /// One image of a site's report, as PNG data.
    ///
    /// - Parameters:
    ///   - index: `1`, `2` or `3`; see ``Designer/SiteReport/numOfImages``.
    ///     Other values are rejected before any request is sent. A missing
    ///     image gives ``SolarEdgeError/notFound(details:)``.
    ///   - siteID: The Designer site.
    public func image(_ index: Int, for siteID: Designer.SiteID) async throws -> Data {
        try validateImageIndex(index)

        return try await client.send(SiteImageEndpoint(site: .id(siteID), index: index))
    }

    /// One image of a site's report, by the site's external ID, as PNG data.
    ///
    /// - Parameters:
    ///   - index: `1`, `2` or `3`; see ``Designer/SiteReport/numOfImages``.
    ///   - externalID: The site's external ID. Must not be empty, `.` or
    ///     `..`, or contain `/`.
    public func image(_ index: Int, forExternalID externalID: String) async throws -> Data {
        try validateImageIndex(index)
        try validateExternalID(externalID)

        return try await client.send(SiteImageEndpoint(site: .externalID(externalID), index: index))
    }
}

/// The spec allows image `1`, `2` or `3`.
func validateImageIndex(_ index: Int) throws {
    guard (1...3).contains(index) else {
        throw SolarEdgeError.invalidRequest("Image index must be 1, 2 or 3, got \(index)")
    }
}

/// External IDs go into the URL path as one segment.
func validateExternalID(_ externalID: String) throws {
    guard !externalID.isEmpty, externalID != ".", externalID != "..", !externalID.contains("/") else {
        throw SolarEdgeError.invalidRequest("Invalid external ID: '\(externalID)'")
    }
}
