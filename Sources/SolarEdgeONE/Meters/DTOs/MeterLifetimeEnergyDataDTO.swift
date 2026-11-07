//
//  MeterLifetimeEnergyDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct MeterLifetimeEnergyDataDTO: Codable {
    let serialNumber: String
    let productionEnergy: [MeasurementDTO]
    let consumptionEnergy: [MeasurementDTO]
    let importEnergy: [MeasurementDTO]
    let exportEnergy: [MeasurementDTO]
    let unit: String
}


extension MeterLifetimeEnergyDataDTO {
    var entity: Monitoring.MeterLifetimeEnergy {
        get throws {
            guard let unit = Monitoring.Energy(rawValue: unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown energy unit for field 'unit'. Value: \(self.unit)")
            }

            return Monitoring.MeterLifetimeEnergy(serialNumber: serialNumber,
                                       unit: unit,
                                       productionEnergy: try productionEnergy.map { try $0.entity },
                                       consumptionEnergy: try consumptionEnergy.map { try $0.entity },
                                       importEnergy: try importEnergy.map { try $0.entity },
                                       exportEnergy: try exportEnergy.map { try $0.entity })
        }
    }
}
