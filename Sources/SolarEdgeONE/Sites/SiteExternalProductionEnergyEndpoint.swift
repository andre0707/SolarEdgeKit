//
//  SiteExternalProductionEnergyEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site External Production Energy. Authentication: API key or OAuth bearer token.
struct SiteExternalProductionEnergyEndpoint: Endpoint {
    typealias Response = SiteExternalProductionEnergyDTO

    let siteID: Monitoring.Site.ID

    /// `GET /sites/{id}/external-production-energy`
    var path: String { "sites/\(siteID.rawValue)/external-production-energy" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}
