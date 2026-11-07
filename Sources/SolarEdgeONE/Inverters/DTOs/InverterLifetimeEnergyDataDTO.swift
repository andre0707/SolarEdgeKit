//
//  InverterLifetimeEnergyDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct InverterLifetimeEnergyDataDTO: Codable {
    let serialNumber: String
    let lifetimeEnergy: [MeasurementDTO]
    let unit: String
}


extension InverterLifetimeEnergyDataDTO {
    var entity: Monitoring.InverterLifetimeEnergy {
        get throws {
            guard let unit = Monitoring.Energy(rawValue: unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown energy unit for field 'unit'. Value: \(self.unit)")
            }

            return Monitoring.InverterLifetimeEnergy(serialNumber: serialNumber,
                                          unit: unit,
                                          values: try lifetimeEnergy.map { try $0.entity })
        }
    }
}
