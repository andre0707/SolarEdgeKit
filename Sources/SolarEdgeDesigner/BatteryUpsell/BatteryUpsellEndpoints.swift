//
//  BatteryUpsellEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Designer.BatteryUpsellTarget {
    /// `sites/{siteId}/designs/{designId}/battery-upsell` or
    /// `layouts/{layoutId}/designs/{designId}/battery-upsell`.
    var path: String {
        switch self {
        case .designerSite(let siteID, let design): "sites/\(siteID.rawValue)/designs/\(design.rawValue)/battery-upsell"
        case .monitoringLayout(let layoutID, let design): "layouts/\(layoutID.rawValue)/designs/\(design.rawValue)/battery-upsell"
        }
    }
}

/// Designer / Monitoring Battery Upsell. Authentication: Designer API key
/// or SolarEdge API key.
struct BatteryUpsellEndpoint: Endpoint {
    typealias Response = BatteryUpsellResponseDTO

    let target: Designer.BatteryUpsellTarget
    let request: BatteryUpsellRequestDTO

    /// `POST /sites/{siteId}/designs/{designId}/battery-upsell` or
    /// `POST /layouts/{layoutId}/designs/{designId}/battery-upsell`
    var path: String { target.path }
    var method: HTTPMethod { .post }
    var body: (any Encodable & Sendable)? { request }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Designer / Monitoring Battery Upsell Financials. Authentication: Designer
/// API key or SolarEdge API key.
struct BatteryUpsellFinancialsEndpoint: Endpoint {
    typealias Response = BatteryUpsellFinancialsResponseDTO

    let target: Designer.BatteryUpsellTarget
    let request: BatteryUpsellFinancialsRequestDTO

    /// `POST …/battery-upsell/financials`
    var path: String { "\(target.path)/financials" }
    var method: HTTPMethod { .post }
    var body: (any Encodable & Sendable)? { request }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}
