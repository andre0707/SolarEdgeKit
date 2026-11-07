//
//  LivePowerFlowStartDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

/// The `200` body of Start Live Power Flow. The spec also says the response
/// has no body, so the endpoint decodes it as optional.
struct LivePowerFlowStartDTO: Codable {
    let status: String
    let refreshRate: Int
}


extension LivePowerFlowStartDTO {
    var entity: Monitoring.LivePowerFlowStart {
        Monitoring.LivePowerFlowStart(status: status, refreshRate: refreshRate)
    }
}
