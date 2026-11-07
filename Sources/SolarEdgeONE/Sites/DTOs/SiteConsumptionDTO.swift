//
//  SiteConsumptionDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SiteConsumptionDTO: Codable {
    let total: Double?
    let unit: String
    let fromPv: Double?
    let fromStorage: Double?
    let fromGrid: Double?
}


extension SiteConsumptionDTO {
    var entity: Monitoring.SiteConsumption {
        get throws {
            guard let unit = Monitoring.Energy(rawValue: unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown energy unit for field 'consumption.unit'. Value: \(self.unit)")
            }

            return Monitoring.SiteConsumption(total: total,
                                   unit: unit,
                                   fromPv: fromPv,
                                   fromStorage: fromStorage,
                                   fromGrid: fromGrid)
        }
    }
}
