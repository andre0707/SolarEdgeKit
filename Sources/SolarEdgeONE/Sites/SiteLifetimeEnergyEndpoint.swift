//
//  SiteLifetimeEnergyEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Lifetime Energy. Authentication: API key or OAuth bearer token.
struct SiteLifetimeEnergyEndpoint: Endpoint {
    typealias Response = SiteLifetimeEnergyDTO

    let siteID: Monitoring.Site.ID

    /// `GET /sites/{id}/lifetime-energy`
    var path: String { "sites/\(siteID.rawValue)/lifetime-energy" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}
