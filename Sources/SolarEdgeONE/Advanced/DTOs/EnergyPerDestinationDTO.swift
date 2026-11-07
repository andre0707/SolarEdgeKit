//
//  EnergyPerDestinationDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `EnergyPerDestination`.
struct EnergyPerDestinationDTO: Codable {
    let siteId: Int
    let production: SiteProductionEnergyDTO
    let consumption: SiteConsumptionEnergyDTO
}

/// `SiteProductionEnergy`.
struct SiteProductionEnergyDTO: Codable {
    let unit: String
    let values: [SiteProductionValueDTO]
}

/// `SiteConsumptionEnergy`.
struct SiteConsumptionEnergyDTO: Codable {
    let unit: String
    let values: [SiteConsumptionValueDTO]
}


extension EnergyPerDestinationDTO {
    var entity: Monitoring.PerDestination<Monitoring.Energy> {
        get throws {
            guard let productionUnit = Monitoring.Energy(rawValue: production.unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unexpected unit for field 'production.unit'. Value: \(production.unit)")
            }
            guard let consumptionUnit = Monitoring.Energy(rawValue: consumption.unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unexpected unit for field 'consumption.unit'. Value: \(consumption.unit)")
            }

            return Monitoring.PerDestination(siteID: .init(rawValue: siteId),
                                  production: .init(unit: productionUnit, values: try production.values.map { try $0.entity }),
                                  consumption: .init(unit: consumptionUnit, values: try consumption.values.map { try $0.entity }))
        }
    }
}
