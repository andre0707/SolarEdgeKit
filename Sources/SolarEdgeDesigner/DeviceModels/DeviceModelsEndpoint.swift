//
//  DeviceModelsEndpoint.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Device Models. Authentication: Designer API key or SolarEdge API key.
struct DeviceModelsEndpoint: Endpoint {
    typealias Response = DeviceModelsDTO

    let gridID: Designer.GridCode.ID
    let countryCode: String?
    let stateCode: String?
    let sector: Designer.DeviceModels.Sector?

    /// `GET /device-models`
    var path: String { "device-models" }

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "gridId", value: gridID.rawValue)]
            + optionalQueryItem("countryCode", countryCode)
            + optionalQueryItem("stateCode", stateCode)
            + optionalQueryItem("sector", sector?.rawValue)
    }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}
