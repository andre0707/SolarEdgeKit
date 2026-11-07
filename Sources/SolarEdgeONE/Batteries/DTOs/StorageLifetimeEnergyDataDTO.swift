//
//  StorageLifetimeEnergyDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct StorageLifetimeEnergyDataDTO: Codable {
    let serialNumber: String
    let lifetimeEnergyCharged: [MeasurementDTO]
    let lifetimeEnergyDischarged: [MeasurementDTO]
    let unit: String
}


extension StorageLifetimeEnergyDataDTO {
    var entity: Monitoring.BatteryLifetimeEnergy {
        get throws {
            guard let unit = Monitoring.Energy(rawValue: unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown energy unit for field 'unit'. Value: \(self.unit)")
            }

            return Monitoring.BatteryLifetimeEnergy(serialNumber: serialNumber,
                                         unit: unit,
                                         charged: try lifetimeEnergyCharged.map { try $0.entity },
                                         discharged: try lifetimeEnergyDischarged.map { try $0.entity })
        }
    }
}
