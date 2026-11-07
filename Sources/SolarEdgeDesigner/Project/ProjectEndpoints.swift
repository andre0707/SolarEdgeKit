//
//  ProjectEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Create Project. Authentication: Designer API key or SolarEdge API key.
struct CreateProjectEndpoint: Endpoint {
    typealias Response = PublicApiResponseDTO

    let parameters: ProjectParamsDTO

    /// `POST /project`
    var path: String { "project" }
    var method: HTTPMethod { .post }
    var body: (any Encodable & Sendable)? { parameters }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Update Project. Authentication: Designer API key or SolarEdge API key.
struct UpdateProjectEndpoint: Endpoint {
    typealias Response = PublicApiResponseDTO

    let siteID: Designer.SiteID
    let parameters: ProjectParamsDTO

    /// `PUT /project/{projectId}`
    var path: String { "project/\(siteID.rawValue)" }
    var method: HTTPMethod { .put }
    var body: (any Encodable & Sendable)? { parameters }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}
