//
//  StorageLifetimeEnergyResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct StorageLifetimeEnergyResponseDTO: Codable {
    let batteries: [StorageLifetimeEnergyDataDTO]
}


extension StorageLifetimeEnergyResponseDTO {
    var entity: [Monitoring.BatteryLifetimeEnergy] {
        get throws {
            try batteries.map { try $0.entity }
        }
    }
}
