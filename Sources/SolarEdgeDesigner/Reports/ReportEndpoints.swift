//
//  ReportEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Identifies a site in the Report Fetching paths: by Designer ID or by
/// the external ID set by the integrator.
enum DesignerSiteReference: Sendable, Hashable {
    case id(Designer.SiteID)
    case externalID(String)

    /// `sites/{siteId}` or `sites/external-id/{externalId}`. The external ID
    /// is percent-encoded when the URL is built.
    var path: String {
        switch self {
        case .id(let id): "sites/\(id.rawValue)"
        case .externalID(let externalID): "sites/external-id/\(externalID)"
        }
    }
}

/// Site Report Data, by ID or external ID. Authentication: Designer API key
/// or SolarEdge API key.
struct SiteReportDataEndpoint: Endpoint {
    typealias Response = ReportDataDTO

    let site: DesignerSiteReference

    /// `GET /sites/{siteId}` or `GET /sites/external-id/{externalId}`
    var path: String { site.path }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Site Image, by ID or external ID. Answers with the raw PNG bytes.
/// Authentication: Designer API key or SolarEdge API key.
struct SiteImageEndpoint: Endpoint {
    typealias Response = Data

    let site: DesignerSiteReference
    let index: Int

    /// `GET /sites/{siteId}/images/{imageId}` or
    /// `GET /sites/external-id/{externalId}/images/{imageId}`
    var path: String { "\(site.path)/images/\(index)" }

    /// PNG on success; JSON for errors.
    var accept: String { "image/png, application/json, application/problem+json" }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}
