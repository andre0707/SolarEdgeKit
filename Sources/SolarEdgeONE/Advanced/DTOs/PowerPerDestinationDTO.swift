//
//  PowerPerDestinationDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `PowerPerDestination`.
struct PowerPerDestinationDTO: Codable {
    let siteId: Int
    let production: SiteProductionPowerDTO
    let consumption: SiteConsumptionPowerDTO
}

/// `SiteProductionPower`.
struct SiteProductionPowerDTO: Codable {
    let unit: String
    let values: [SiteProductionValueDTO]
}

/// `SiteConsumptionPower`.
struct SiteConsumptionPowerDTO: Codable {
    let unit: String
    let values: [SiteConsumptionValueDTO]
}


extension PowerPerDestinationDTO {
    var entity: Monitoring.PerDestination<Monitoring.Power> {
        get throws {
            guard let productionUnit = Monitoring.Power(rawValue: production.unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unexpected unit for field 'production.unit'. Value: \(production.unit)")
            }
            guard let consumptionUnit = Monitoring.Power(rawValue: consumption.unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unexpected unit for field 'consumption.unit'. Value: \(consumption.unit)")
            }

            return Monitoring.PerDestination(siteID: .init(rawValue: siteId),
                                  production: .init(unit: productionUnit, values: try production.values.map { try $0.entity }),
                                  consumption: .init(unit: consumptionUnit, values: try consumption.values.map { try $0.entity }))
        }
    }
}
