//
//  InverterLifetimeEnergyResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct InverterLifetimeEnergyResponseDTO: Codable {
    let period: PeriodDTO
    let unit: String
    let resolution: String
    let lifetimeEnergy: [MeasurementDTO]
}


extension InverterLifetimeEnergyResponseDTO {
    /// Same shape as any other time series, only the values field is named
    /// `lifetimeEnergy`.
    var entity: Monitoring.Measurements<Monitoring.Energy> {
        get throws {
            try MeasurementsDTO(period: period, unit: unit, resolution: resolution, values: lifetimeEnergy)
                .entity(unit: Monitoring.Energy.self)
        }
    }
}
