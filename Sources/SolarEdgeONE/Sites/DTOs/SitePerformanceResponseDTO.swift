//
//  SitePerformanceResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SitePerformanceResponseDTO: Codable {
    let siteId: Int
    let performance: SitePerformanceDTO
}


extension SitePerformanceResponseDTO {
    var entity: Monitoring.SitePerformance {
        Monitoring.SitePerformance(siteID: .init(rawValue: siteId),
                        specificYield: performance.specificYield,
                        performanceRatio: performance.performanceRatio)
    }
}
