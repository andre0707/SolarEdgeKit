//
//  ProjectService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The Designer Project API: create and update projects (sites) in Designer.
///
/// Values outside the ranges the spec gives are rejected before any request
/// is sent. All methods accept a Designer API key or a SolarEdge API key.
public struct ProjectService: Sendable {
    let client: APIClient

    /// Creates a project.
    ///
    /// If the modules cannot all be wired, the API answers `400` with a
    /// message, which ends up in ``SolarEdgeError/http(statusCode:details:)``.
    ///
    /// - Returns: The new site's ID and its URL in Designer.
    public func create(_ parameters: Designer.ProjectParameters) async throws -> Designer.ProjectSite {
        try parameters.validate()

        return try await client.send(CreateProjectEndpoint(parameters: ProjectParamsDTO(parameters.asUpdate))).entity
    }

    /// Updates a project. Only the values set in `update` are changed.
    ///
    /// - Parameters:
    ///   - siteID: The project's site, e.g. from ``create(_:)``.
    ///   - update: The values to change.
    /// - Returns: The site's ID and its URL in Designer.
    public func update(_ siteID: Designer.SiteID, with update: Designer.ProjectUpdate) async throws -> Designer.ProjectSite {
        try update.validate()

        return try await client.send(UpdateProjectEndpoint(siteID: siteID, parameters: ProjectParamsDTO(update))).entity
    }
}
