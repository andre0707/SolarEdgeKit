//
//  SiteConfigurationEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Weather Guard Configuration. Authentication: API key or OAuth bearer token.
struct WeatherGuardEndpoint: Endpoint {
    typealias Response = WeatherGuardDTO

    let siteID: Monitoring.Site.ID

    /// `GET /sites/{id}/weather-guard`
    var path: String { "sites/\(siteID.rawValue)/weather-guard" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}

/// Battery Backup Reserve Configuration. Authentication: API key or OAuth
/// bearer token.
struct BatteryBackupReserveEndpoint: Endpoint {
    typealias Response = BatteryBackupReserveDTO

    let siteID: Monitoring.Site.ID

    /// `GET /sites/{id}/backup-reserve`
    var path: String { "sites/\(siteID.rawValue)/backup-reserve" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}
