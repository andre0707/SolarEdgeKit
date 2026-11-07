//
//  SiteProductionDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SiteProductionDTO: Codable {
    let total: Double
    let unit: String
    let toSelfConsumption: Double?
    let toStorage: Double?
    let toGrid: Double?
}


extension SiteProductionDTO {
    var entity: Monitoring.SiteProduction {
        get throws {
            guard let unit = Monitoring.Energy(rawValue: unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown energy unit for field 'production.unit'. Value: \(self.unit)")
            }

            return Monitoring.SiteProduction(total: total,
                                  unit: unit,
                                  toSelfConsumption: toSelfConsumption,
                                  toStorage: toStorage,
                                  toGrid: toGrid)
        }
    }
}
