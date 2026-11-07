//
//  SiteSummaryDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SiteSummaryDTO: Codable {
    let siteId: Int
    let production: SiteProductionDTO
    let consumption: SiteConsumptionDTO
}


extension SiteSummaryDTO {
    var entity: Monitoring.SiteOverview {
        get throws {
            Monitoring.SiteOverview(siteID: .init(rawValue: siteId),
                         production: try production.entity,
                         consumption: try consumption.entity)
        }
    }
}
