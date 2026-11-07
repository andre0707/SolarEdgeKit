//
//  AutoDesignService.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// The Designer Auto Design API: creates a site from coordinates and a
/// name, generates its 3D model, places PV panels and generates the
/// electrical design.
///
/// The design runs asynchronously: ``start(_:)`` returns a request ID, and
/// ``status(of:)`` reports the progress. Both accept a Designer API key or a
/// SolarEdge API key.
public struct AutoDesignService: Sendable {
    let client: APIClient

    /// Starts an Auto Design.
    ///
    /// An empty site name or out-of-range coordinates are rejected before
    /// any request is sent.
    ///
    /// - Returns: The request, for ``status(of:)``, and the new site's ID.
    public func start(_ parameters: Designer.AutoDesignParameters) async throws -> Designer.AutoDesignRequest {
        try parameters.validate()

        return try await client.send(CreateAutoDesignEndpoint(parameters: AutoDesignParametersDTO(parameters))).entity
    }

    /// The latest status of an Auto Design.
    ///
    /// - Parameter requestID: From ``start(_:)``. Must not be empty.
    public func status(of requestID: Designer.AutoDesignRequest.ID) async throws -> Designer.AutoDesignStatus {
        try validateRequired(requestID.rawValue, name: "requestId")

        return try await client.send(AutoDesignStatusEndpoint(requestID: requestID)).entity
    }
}
