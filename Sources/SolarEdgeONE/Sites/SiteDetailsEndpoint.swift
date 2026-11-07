//
//  SiteDetailsEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Details. Authentication: API key or OAuth bearer token.
struct SiteDetailsEndpoint: Endpoint {
    typealias Response = SiteMetadataExtendedDTO

    let siteID: Monitoring.Site.ID

    /// `GET /sites/{id}`
    var path: String { "sites/\(siteID.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}
