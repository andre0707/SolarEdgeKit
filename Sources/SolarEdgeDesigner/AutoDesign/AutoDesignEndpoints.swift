//
//  AutoDesignEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Create Auto Design. Authentication: Designer API key or SolarEdge API key.
struct CreateAutoDesignEndpoint: Endpoint {
    typealias Response = AutoDesignResponseDTO

    let parameters: AutoDesignParametersDTO

    /// `POST /auto-design`
    var path: String { "auto-design" }
    var method: HTTPMethod { .post }
    var body: (any Encodable & Sendable)? { parameters }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Auto Design Status. Authentication: Designer API key or SolarEdge API key.
struct AutoDesignStatusEndpoint: Endpoint {
    typealias Response = AutoDesignStatusResponseDTO

    let requestID: Designer.AutoDesignRequest.ID

    /// `GET /auto-design/status`
    var path: String { "auto-design/status" }

    var queryItems: [URLQueryItem] { [URLQueryItem(name: "requestId", value: requestID.rawValue)] }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}
