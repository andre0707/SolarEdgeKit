//
//  EstimationReportEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Generate Estimation. Authentication: Designer API key or SolarEdge API key.
struct GenerateEstimationEndpoint: Endpoint {
    typealias Response = EstimationDTO

    let parameters: EstimationParamsDTO

    /// `POST /estimation`
    var path: String { "estimation" }
    var method: HTTPMethod { .post }
    var body: (any Encodable & Sendable)? { parameters }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Site Report, for the site's default design. Authentication: Designer API
/// key or SolarEdge API key.
struct SiteEstimationEndpoint: Endpoint {
    typealias Response = SiteEstimationDTO

    let siteID: Designer.SiteID

    /// `GET /report/sites/{siteId}`
    var path: String { "report/sites/\(siteID.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Site Design Report. Authentication: Designer API key or SolarEdge API key.
struct SiteDesignEstimationEndpoint: Endpoint {
    typealias Response = EstimationDTO

    let siteID: Designer.SiteID
    let designID: Designer.DesignID

    /// `GET /report/sites/{siteId}/designs/{designId}`
    var path: String { "report/sites/\(siteID.rawValue)/designs/\(designID.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}
