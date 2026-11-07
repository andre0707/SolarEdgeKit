//
//  MeterLifetimeEnergyResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct MeterLifetimeEnergyResponseDTO: Codable {
    let meters: [MeterLifetimeEnergyDataDTO]
}


extension MeterLifetimeEnergyResponseDTO {
    var entity: [Monitoring.MeterLifetimeEnergy] {
        get throws {
            try meters.map { try $0.entity }
        }
    }
}
