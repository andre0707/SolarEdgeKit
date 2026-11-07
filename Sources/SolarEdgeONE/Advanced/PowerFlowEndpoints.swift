//
//  PowerFlowEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Power Flow. Authentication: API key or OAuth bearer token.
struct SitePowerFlowEndpoint: Endpoint {
    typealias Response = SitePowerFlowDTO

    let siteID: Monitoring.Site.ID

    /// `GET /sites/{id}/power-flow`
    var path: String { "sites/\(siteID.rawValue)/power-flow" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}

/// Start Live Power Flow. Authentication: API key, or an OAuth bearer token
/// with the `SITE_DATA` scope.
struct StartLivePowerFlowEndpoint: Endpoint {
    /// The spec says the `200` has no body, but also describes one.
    typealias Response = LivePowerFlowStartDTO?

    let siteID: Monitoring.Site.ID

    var method: HTTPMethod { .post }

    /// `POST /sites/{id}/power-flow`
    var path: String { "sites/\(siteID.rawValue)/power-flow" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}
