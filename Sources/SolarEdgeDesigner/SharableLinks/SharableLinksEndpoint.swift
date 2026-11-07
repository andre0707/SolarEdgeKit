//
//  SharableLinksEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Sharable Links, for a site's default design or one design, by ID or
/// external ID. Authentication: Designer API key or SolarEdge API key.
struct SharableLinksEndpoint: Endpoint {
    typealias Response = SharableLinksResponseDTO

    let site: DesignerSiteReference
    let design: Designer.DesignID?
    let locale: String?
    let units: Designer.UnitSystem?

    /// `GET /report/sites/{siteId}[/designs/{designId}]/sharable-links` or
    /// `GET /report/external-id/{externalId}[/designs/{designId}]/sharable-links`
    var path: String {
        let site = switch site {
        case .id(let id): "report/sites/\(id.rawValue)"
        case .externalID(let externalID): "report/external-id/\(externalID)"
        }
        let design = design.map { "/designs/\($0.rawValue)" } ?? ""
        return "\(site)\(design)/sharable-links"
    }

    var queryItems: [URLQueryItem] {
        optionalQueryItem("locale", locale) + optionalQueryItem("units", units?.rawValue)
    }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}
