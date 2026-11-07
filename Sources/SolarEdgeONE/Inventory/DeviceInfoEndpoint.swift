//
//  DeviceInfoEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Device Info. Authentication: API key or OAuth bearer token.
struct DeviceInfoEndpoint: Endpoint {
    typealias Response = DeviceDataDTO

    let siteID: Monitoring.Site.ID
    let serialNumber: String

    /// `GET /sites/{id}/devices/{serialNumber}`
    var path: String { "sites/\(siteID.rawValue)/devices/\(serialNumber)" }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}
