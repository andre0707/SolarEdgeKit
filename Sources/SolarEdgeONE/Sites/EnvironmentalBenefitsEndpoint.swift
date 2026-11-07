//
//  EnvironmentalBenefitsEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct EnvironmentalBenefitsEndpoint: Endpoint {
    typealias Response = EnvironmentalBenefitsDTO

    let siteID: Monitoring.Site.ID
    let unit: Monitoring.UnitSystem

    var path: String { "sites/\(siteID.rawValue)/environmental-benefits" }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "unit", value: unit.rawValue)]
    }

    var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
}
