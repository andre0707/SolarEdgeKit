//
//  SiteInverterLifetimeEnergyResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SiteInverterLifetimeEnergyResponseDTO: Codable {
    let inverters: [InverterLifetimeEnergyDataDTO]
}


extension SiteInverterLifetimeEnergyResponseDTO {
    var entity: [Monitoring.InverterLifetimeEnergy] {
        get throws {
            try inverters.map { try $0.entity }
        }
    }
}
